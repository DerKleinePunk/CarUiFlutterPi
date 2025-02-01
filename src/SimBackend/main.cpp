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

INITIALIZE_EASYLOGGINGPP

// Logic and data behind the server's behavior.
class GreeterServiceImpl final : public helloworld::Greeter::Service {
  grpc::Status SayHello(grpc::ServerContext* context, const helloworld::HelloRequest* request,
                  helloworld::HelloReply* reply) override {
    std::string prefix("Hello ");
    reply->set_message(prefix + request->name());
    return grpc::Status::OK;
  }
};

void RunServer(uint16_t port) {
  std::string server_address = absl::StrFormat("0.0.0.0:%d", port);
  GreeterServiceImpl service;

  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();
  grpc::ServerBuilder builder;
  // Listen on the given address without any authentication mechanism.
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  // Register "service" as the instance through which we'll communicate with
  // clients. In this case it corresponds to an *synchronous* service.
  builder.RegisterService(&service);
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
    int server_socket = -1;

    std::cout << "Starting Sim Backend " << PROJECT_VER << std::endl;
    START_EASYLOGGINGPP(argc, argv);

    el::Helpers::setThreadName("Main");
    el::Loggers::getLogger(ELPP_DEFAULT_LOGGER);

    unlink(socketPath); //If already exits
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
    }

    RunServer(5001);

    std::cout << "Enter q to Stop" << std::endl;

    std::string input;
    std::cin >> input;
    /*while(input != "q") {
        std::cin >> input;
    }*/

    delete socketController;
    
    unlink(socketPath);

    return exit_code;
}