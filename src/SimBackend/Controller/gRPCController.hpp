#pragma once

#include <thread>

#include <grpc/grpc.h>
#include <grpcpp/security/server_credentials.h>
#include <grpcpp/server.h>

class gRPCController
{
private:
    std::thread _loopThread;
    std::unique_ptr<grpc::Server> _server;
    void Loop();
public:
    gRPCController(/* args */);
    ~gRPCController();

    void Run(uint16_t port);
    void Stop();
};
