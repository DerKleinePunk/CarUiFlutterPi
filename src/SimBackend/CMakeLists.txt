project("SimBackend" VERSION "${RELEASE_VERSION}" LANGUAGES CXX)

MESSAGE(STATUS "Try Build ${PROJECT_NAME} in Version ${RELEASE_VERSION}")

## Use all the *.cpp files we found under this folder for the project Find better way for coomen cpp files
FILE(GLOB SRCS "*.cpp" "*/*.cpp")

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows" )
    SET (project_BIN ${PROJECT_NAME})
else()
    SET (project_BIN ${PROJECT_NAME}.bin)
endif()

INCLUDE_DIRECTORIES(${UDEV_INCLUDE_DIR})

set(PROTO_FILES
    "../protos/helloworld.proto"
    "../protos/carconnect.proto"
)

get_target_property(grpc_cpp_plugin_location gRPC::grpc_cpp_plugin LOCATION)

include_directories(${Protobuf_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR})
protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILES})
protobuf_generate_cpp(PROTO_GPRC_SRCS PROTO_GPRC_HDRS ${PROTO_FILES} LANGUAGE grpc GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc PLUGIN "protoc-gen-grpc=${grpc_cpp_plugin_location}")

message(STATUS "PROTO_SRCS ${PROTO_SRCS} PROTO_HDRS ${PROTO_HDRS}")
message(STATUS "PROTO_GPRC_SRCS ${PROTO_GPRC_SRCS} PROTO_GPRC_HDRS ${PROTO_GPRC_HDRS}")

add_executable(${project_BIN} ${SRCS} ${PROTO_SRCS} ${PROTO_HDRS} ${PROTO_GPRC_SRCS} ${PROTO_GPRC_HDRS} ${easylogging_SRCS})

TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE systemd)
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE protobuf::libprotobuf)
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE gRPC::grpc)
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE gRPC::grpc++)
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE gRPC::grpc++_reflection)
#missing absl::check absl::log
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE absl::flags absl::flags_parse)
