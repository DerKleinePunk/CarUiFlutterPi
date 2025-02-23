#pragma once

#include <thread>
#include <condition_variable>

#include <grpc/grpc.h>
#include <grpcpp/security/server_credentials.h>
#include <grpcpp/server.h>

class gRPCController
{
private:
    std::thread _loopThread;
    std::unique_ptr<grpc::Server> _server;
    std::condition_variable _cv;
    std::mutex _mutex;
    void Loop();
public:
    gRPCController(/* args */);
    ~gRPCController();

    void Run(uint16_t port);
    void Stop();
};
