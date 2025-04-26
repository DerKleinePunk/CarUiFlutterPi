#ifndef ELPP_DEFAULT_LOGGER
#define ELPP_DEFAULT_LOGGER "gRPCController"
#endif
#ifndef ELPP_CURR_FILE_PERFORMANCE_LOGGER_ID
#define ELPP_CURR_FILE_PERFORMANCE_LOGGER_ID ELPP_DEFAULT_LOGGER
#endif

#include "gRPCController.hpp"

#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <absl/strings/str_format.h>
#include <grpcpp/ext/proto_server_reflection_plugin.h>
#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>
#include <helloworld.grpc.pb.h>

#include <chrono>
#include <condition_variable>

#include "../../common/easylogging/easylogging++.h"

using namespace std::chrono_literals;

char socketPath[] = "/tmp/SimBackend.sock";

// https://github.com/grpc/grpc/blob/v1.66.0/examples/cpp/route_guide/route_guide_server.cc

// TODO clean this stupy code
class HelloReactor;

HelloReactor* g_helloReactor = nullptr;

class HelloReactor final : public grpc::ServerWriteReactor<helloworld::HelloReply>
{
public:
  HelloReactor() : messages_to_send_(3), _newMessageWait(_mutexNewMessage)
  {
    res_.set_message(std::string(5, '#'));
    std::cout << "ctor\n";
    Write();
    g_helloReactor = this;
    _stopRequested = false;
  }

  void Write()
  {
    absl::MutexLock lock(&mu_);
    StartWrite(&res_);
    --messages_to_send_;
    write_start_time_ = absl::Now();
  }

  void WriteText(const std::string& message)
  {
    absl::MutexLock lock(&mu_);
    res_.set_message(message);
    ++messages_to_send_;
    _cvNewMessage.notify_all();
  }

  void OnWriteDone(bool ok) override
  {
    bool more = false;
    {
      absl::MutexLock lock(&mu_);
      std::cout << "Write #" << messages_to_send_ << " done (Ok: " << ok
                << "): " << absl::Now() - *write_start_time_ << "\n";
      write_start_time_ = std::nullopt;
      more = ok && messages_to_send_ > 0;
    }
    if(more) {
      Write();
    } else {
      LOG(DEBUG) << "Done sending messages with ok " << ok << " _stopRequested " << _stopRequested;
      if(_stopRequested || !ok) {
        Finish(grpc::Status::OK);
        return;
      }

      if(_cvNewMessage.wait_for(_newMessageWait, 2s) == std::cv_status::timeout) {
        if(!_stopRequested) {
          messages_to_send_++;
          res_.set_message("alive");
          Write();
        } else {
          messages_to_send_++;
          res_.set_message("bye bye");
          Write();
        }
      } else {
        Write();
      }
    }
  }

  void OnDone() override
  {
    std::cout << "Channel Closed\n";
    g_helloReactor = nullptr;
    delete this;
  }

  bool _stopRequested;

private:
  helloworld::HelloReply res_;
  size_t messages_to_send_;
  std::optional<absl::Time> write_start_time_;
  absl::Mutex mu_;

  std::condition_variable _cvNewMessage;
  std::mutex _mutexNewMessage;
  std::unique_lock<std::mutex> _newMessageWait;
};


// Logic and data behind the server's behavior.
class GreeterServiceImpl final : public helloworld::Greeter::CallbackService
{
  grpc::ServerUnaryReactor* SayHello(grpc::CallbackServerContext* context,
                                     const helloworld::HelloRequest* request,
                                     helloworld::HelloReply* reply) override
  {
    std::string prefix("Hello ");
    reply->set_message(prefix + request->name());

    std::cout << "Say Hello was called" << std::endl;

    auto* reactor = context->DefaultReactor();
    reactor->Finish(grpc::Status::OK);
    return reactor;
  }

  grpc::ServerWriteReactor<helloworld::HelloReply>* SayHelloStreamReply(grpc::CallbackServerContext* /*context*/, const helloworld::HelloRequest* request) override
  {
    return new HelloReactor();
  }

};

void gRPCController::Loop(/* args */)
{
  el::Helpers::setThreadName("gRPCController");

  GreeterServiceImpl service;

  std::string server_address = absl::StrFormat("0.0.0.0:%d", _tcpServerPort);
  std::string server_address2 = absl::StrFormat("unix:%s", socketPath);

  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();

  grpc::ServerBuilder builder;
  // Listen on the given address without any authentication mechanism.
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  builder.AddListeningPort(server_address2, grpc::InsecureServerCredentials());
  // Register "service" as the instance through which we'll communicate with
  // clients. In this case it corresponds to an *synchronous* service.
  builder.RegisterService(&service);
  // Set Alives
  builder.AddChannelArgument(GRPC_ARG_KEEPALIVE_TIME_MS, 10 * 60 * 1000 /*10 min*/);
  builder.AddChannelArgument(GRPC_ARG_KEEPALIVE_TIMEOUT_MS, 20 * 1000 /*20 sec*/);
  builder.AddChannelArgument(GRPC_ARG_KEEPALIVE_PERMIT_WITHOUT_CALLS, 1);
  builder.AddChannelArgument(GRPC_ARG_HTTP2_MIN_RECV_PING_INTERVAL_WITHOUT_DATA_MS, 10 * 1000 /*10 sec*/);

  // Finally assemble the server.
  _server = builder.BuildAndStart();
  _health_check_service = _server->GetHealthCheckService();
  _health_check_service->SetServingStatus(true);

  // std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << server_address << std::endl;
  std::cout << "Server listening on " << server_address2 << std::endl;

  _cv.notify_all();
  // Wait for the server to shutdown. Note that some other thread must be
  // responsible for shutting down the server for this call to ever return.
  _server->Wait();
}


gRPCController::gRPCController(/* args */)
{
  el::Loggers::getLogger(ELPP_DEFAULT_LOGGER);
  _health_check_service = nullptr;
}

gRPCController::~gRPCController()
{
}

void gRPCController::Run(uint16_t port)
{
  _tcpServerPort = port;

  std::unique_lock<std::mutex> startUpWait(_mutex);
  _loopThread = std::thread(&gRPCController::Loop, this);
  if(_cv.wait_for(startUpWait, 2s) == std::cv_status::timeout) {
    LOG(ERROR) << "Timeout Starting GPRC Server";
  }
  //_server->Wait();
}

void gRPCController::Stop()
{
  if(_health_check_service != nullptr) {
    _health_check_service->SetServingStatus(false);
  }

  if(_loopThread.joinable()) {
    _stopRequested = true;
    if(g_helloReactor != nullptr) {
      g_helloReactor->_stopRequested = true;
    }
    _server->Shutdown();

    _loopThread.join();
  }
}

void gRPCController::SendTestMessage()
{
  if(g_helloReactor == nullptr) {
    LOG(WARNING) << "g_helloReactor is null";
    return;
  }

  LOG(DEBUG) << "Try add New Message";

  auto text = std::string("From Console");
  g_helloReactor->WriteText(text);
}
