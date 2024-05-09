#ifndef ELPP_DEFAULT_LOGGER
#define ELPP_DEFAULT_LOGGER "SocketController"
#endif
#ifndef ELPP_CURR_FILE_PERFORMANCE_LOGGER_ID
#define ELPP_CURR_FILE_PERFORMANCE_LOGGER_ID ELPP_DEFAULT_LOGGER
#endif

#include "SocketController.hpp"

#include <fcntl.h>
#include <pwd.h>
#include <sys/ioctl.h>
#include <sys/poll.h>
#include <sys/socket.h>
#include <unistd.h>
#include <thread>

#include "../../common/easylogging/easylogging++.h"

void SocketController::Loop()
{
    el::Helpers::setThreadName("SocketController");
    LOG(INFO) << "Socket thread is running";

    _watchSockets.push_back(_listenSocket);
    _watchSockets.push_back(_internPipe[0]);

    BuildFds();

    while(_run) {
        // Detect activity on the sockets
        // -1 forever
        if(poll(_fds, _watchSockets.size(), -1) == -1) {
            if(!_run) {
                break;
            } else {
                // error case
                continue;
            }
        }

        if(!_run) {
            break;
        }

        // Run through the existing connections looking for data to be read
        for(std::size_t pos = 0; pos < _watchSockets.size(); pos++) {
            if(_fds[pos].revents == 0) {
                // this socket nothing to do
                continue;
            }

            if(!(_fds[pos].revents & POLLIN) && !(_fds[pos].revents & POLLHUP)) {
                // printf("  Error! revents = %d\n", fds[i].revents);
                // Todo Handle it
                continue;
            }

            if(_fds[pos].fd == _listenSocket) {
                HandleAccept();
            } else if(_fds[pos].fd == _internPipe[0]) {
                char c;

                if(read(_internPipe[0], &c, 1) != 1) {
                    // error
                }
            } else {
                try {
                    if(_fds[pos].revents & POLLIN) {
                        HandleReceived(_fds[pos].fd);
                    }
                    if(_fds[pos].revents & POLLHUP) {
                        HandleClosed(_fds[pos].fd);
                        BuildFds();
                    }
                } catch(...) {
                    if(!_run) {
                        break;
                    }
                    HandleClosed(_fds[pos].fd);
                    BuildFds();
                }
            }
        }
    }

    for(std::size_t pos = 2; pos < _watchSockets.size(); pos++) {
        close(_watchSockets[pos]);
    }

    LOG(INFO) << "Socket thread is stopped";
}

void SocketController::HandleAccept()
{
        // A client is asking a new connection
    socklen_t addrlen;
    struct sockaddr_storage clientaddr;
    int newSocket;

    // Handle a new connection
    addrlen = sizeof(clientaddr);
    memset(&clientaddr, 0, sizeof(clientaddr));

    newSocket = accept(_listenSocket, reinterpret_cast<struct sockaddr*>(&clientaddr), &addrlen);

    if(newSocket != -1) {
        // save the socket
        _watchSockets.push_back(newSocket);
        BuildFds();
    } else {
        LOG(ERROR) << "Server accept() error";
    }
}

void SocketController::HandleReceived(int socket)
{
    // We received request

    // get credential info
    struct ucred cred;
    socklen_t lenCredStruct = sizeof(struct ucred);

    if(getsockopt(socket, SOL_SOCKET, SO_PEERCRED, &cred, &lenCredStruct) == -1) {
        throw std::runtime_error("Impossible to get sender");
    }

    passwd* pws;
    pws = getpwuid(cred.uid);

    std::string sender(pws->pw_name);

    int bytes;
    ioctl(socket, FIONREAD, &bytes);

    const auto buffer = new char[bytes + 1];
    memset(buffer, 0, bytes + 1);
    const auto count = read(socket, buffer, bytes);

    std::string bufferText(buffer, count);

    LOG(INFO) << "sender " << sender << " " << bufferText;

    if(bufferText == "die\n") {
        /*auto message = new WorkerMessage();
        message->_messageType = worker_message_type::die;
        const auto rc = write(_backendPipe, &message, sizeof(message));
        if(rc != sizeof(message)) {
            LOG(ERROR) << "Writing intern Pipe " << strerror(errno);
        } else {
            SendAll(std::string("selbstmord\n"));
        }*/
    } else {
        try {
            /*const auto jsonText = json::parse(buffer);
            auto message = new WorkerMessage();
            message->_messageType = worker_message_type::controller;
            message->_messageJson = jsonText;
            const auto rc = write(_backendPipe, &message, sizeof(message));
            if(rc != sizeof(message)) {
                LOG(ERROR) << "Writing intern Pipe " << strerror(errno);
            }*/
        } catch(const std::exception& e) {
            LOG(ERROR) << e.what();
        }
    }
    delete[] buffer;
}

void SocketController::HandleClosed(int socket)
{
    close(socket);
    int pos = 0;
    for(const auto entry : _watchSockets) {
        if(entry == socket) {
            _watchSockets.erase(_watchSockets.begin() + pos);
            break;
        }
        pos++;
    }
}

void SocketController::BuildFds()
{
    memset(_fds, 0, sizeof(_fds));
    int pos = 0;
    for(const auto entry : _watchSockets) {
        LOG(INFO) << "watch fd " << entry;
        _fds[pos].fd = entry;
        if(pos > 1) {
            _fds[pos].events = POLLIN | POLLHUP;
        } else {
            _fds[pos].events = POLLIN;
        }

        pos++;
    }
}

SocketController::SocketController(int listenSocket)
{
    el::Loggers::getLogger(ELPP_DEFAULT_LOGGER);
    _listenSocket = listenSocket;
    _internPipe[0] = -1;
    _internPipe[1] = -1;
    _run = false;
}

SocketController::~SocketController()
{
     if(_loopThread.joinable()) {
        _run = false;
        if(write(_internPipe[1], "s", 1) != -1) {
            // error
        }

        _loopThread.join();
    }
}

int SocketController::Start()
{
    auto result = pipe(_internPipe);

    if(result < 0) {
        LOG(ERROR) << "Impossible to create the pipe";
        return result;
    }

    _run = true;

    _loopThread = std::thread(&SocketController::Loop, this);
    
    return result;
}