#ifndef ELPP_DEFAULT_LOGGER
#define ELPP_DEFAULT_LOGGER "Main"
#endif
#ifndef ELPP_CURR_FILE_PERFORMANCE_LOGGER_ID
#define ELPP_CURR_FILE_PERFORMANCE_LOGGER_ID ELPP_DEFAULT_LOGGER
#endif

#include <iostream>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/un.h>
#include <fcntl.h>
#include <libudev.h> 

#include <grpcpp/ext/proto_server_reflection_plugin.h>
#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>
#include <absl/flags/flag.h>
#include <absl/flags/parse.h>
#include <absl/strings/str_format.h>

#include <helloworld.grpc.pb.h>

#include "../common/version.hpp"
#include "../common/easylogging/easylogging++.h"
#include "Controller/SocketController.hpp"

char socketPath[] = "/tmp/SimBackend.sock";

volatile std::sig_atomic_t g_shutdown_flag = 0;

INITIALIZE_EASYLOGGINGPP

class HelloReactor final
    : public grpc::ServerWriteReactor<helloworld::HelloReply> {
 public:
  HelloReactor()
      : messages_to_send_(3) {
    res_.set_message(std::string(5, '#'));
    std::cout << "ctor\n";
    Write();
  }

  void Write() {
    absl::MutexLock lock(&mu_);
    StartWrite(&res_);
    --messages_to_send_;
    write_start_time_ = absl::Now();
  }

  void OnWriteDone(bool ok) override {
    bool more = false;
    {
      absl::MutexLock lock(&mu_);
      std::cout << "Write #" << messages_to_send_ << " done (Ok: " << ok
                << "): " << absl::Now() - *write_start_time_ << "\n";
      write_start_time_ = std::nullopt;
      more = ok && messages_to_send_ > 0;
    }
    if (more) {
      Write();
    } else {
      Finish(grpc::Status::OK);
      std::cout << "Done sending messages\n";
    }
  }

  void OnDone() override { 
    std::cout << "Channel Closed\n";
    delete this; 
  }

 private:
  helloworld::HelloReply res_;
  size_t messages_to_send_;
  std::optional<absl::Time> write_start_time_;
  absl::Mutex mu_;
};

// Logic and data behind the server's behavior.
class GreeterServiceImpl final : public helloworld::Greeter::CallbackService {
  grpc::ServerUnaryReactor* SayHello(grpc::CallbackServerContext* context, const helloworld::HelloRequest* request,
                  helloworld::HelloReply* reply) override {
    std::string prefix("Hello ");
    reply->set_message(prefix + request->name());

    std::cout << "Say Hello was called" << std::endl;

    auto* reactor = context->DefaultReactor();
    reactor->Finish(grpc::Status::OK);
    return reactor;
  }

  grpc::ServerWriteReactor<helloworld::HelloReply>* SayHelloStreamReply(
      grpc::CallbackServerContext* /*context*/,
      const helloworld::HelloRequest* request) override {
    return new HelloReactor();
  }
};

void RunServer(uint16_t port) {
  std::string server_address = absl::StrFormat("0.0.0.0:%d", port);
  std::string server_address2 = absl::StrFormat("unix:%s", socketPath);
  GreeterServiceImpl service;

  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();
  grpc::ServerBuilder builder;
  // Listen on the given address without any authentication mechanism.
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  builder.AddListeningPort(server_address2, grpc::InsecureServerCredentials());
  // Register "service" as the instance through which we'll communicate with
  // clients. In this case it corresponds to an *synchronous* service.
  builder.RegisterService(&service);
  //Set Alives
  builder.AddChannelArgument(GRPC_ARG_KEEPALIVE_TIME_MS,10 * 60 * 1000 /*10 min*/);
  builder.AddChannelArgument(GRPC_ARG_KEEPALIVE_TIMEOUT_MS,20 * 1000 /*20 sec*/);
  builder.AddChannelArgument(GRPC_ARG_KEEPALIVE_PERMIT_WITHOUT_CALLS, 1);
  builder.AddChannelArgument(GRPC_ARG_HTTP2_MIN_RECV_PING_INTERVAL_WITHOUT_DATA_MS,10 * 1000 /*10 sec*/);

  // Finally assemble the server.
  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << server_address << std::endl;

  // Wait for the server to shutdown. Note that some other thread must be
  // responsible for shutting down the server for this call to ever return.
  server->Wait();
}

int main(int argc, char** argv)
{
    int exit_code = EXIT_SUCCESS;
    //int server_socket = -1;
    // Sample with Systemdd sieh https://github.com/grpc/grpc/tree/master/examples/cpp/systemd_socket_activation

    std::cout << "Starting Sim Backend " << PROJECT_VER << std::endl;
    START_EASYLOGGINGPP(argc, argv);

    el::Helpers::setThreadName("Main");
    el::Loggers::getLogger(ELPP_DEFAULT_LOGGER);

    /*unlink(socketPath); //If already exits
    server_socket = socket(AF_UNIX, SOCK_STREAM, PF_UNSPEC);
    sockaddr_un name;
    memset(&name, 0, sizeof(sockaddr_un));
    name.sun_family = AF_UNIX;
    strncpy(name.sun_path, socketPath, sizeof(name.sun_path) - 1);
    
    auto functionResult = bind(server_socket, reinterpret_cast<const sockaddr*>(&name), sizeof(sockaddr_un));
    if(functionResult == -1) {
        //Todo Error
    }

    //Max Connections 5
    functionResult = listen(server_socket, 5);
    if (functionResult == -1) {
        //Todo Error
    }

    auto socketController = new SocketController(server_socket);
    
    functionResult = socketController->Start();
    if (functionResult != 0) {
        //Todo Error
    }*/

    RunServer(5001);

    std::cout << "Enter q to Stop" << std::endl;

    std::string input;
    std::cin >> input;
    /*while(input != "q") {
        std::cin >> input;
    }*/

    //delete socketController;
    
    //unlink(socketPath);

    return exit_code;
}