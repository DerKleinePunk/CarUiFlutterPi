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

#include "../common/version.hpp"
#include "../common/easylogging/easylogging++.h"
#include "Controller/SocketController.hpp"
#include "Controller/gRPCController.hpp"

volatile std::sig_atomic_t g_shutdown_flag = 0;

INITIALIZE_EASYLOGGINGPP

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

    gRPCController test;
    test.Run(5001);

    std::cout << "Enter q to Stop" << std::endl;

    std::string input;
    std::cin >> input;
    while(input != "q") {
        std::cin >> input;
    }

    test.Stop();
    
    //delete socketController;
    
    //unlink(socketPath);

    return exit_code;
}