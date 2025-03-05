project("SimBackend" VERSION "${RELEASE_VERSION}" LANGUAGES CXX)

MESSAGE(STATUS "Try Build ${PROJECT_NAME} in Version ${RELEASE_VERSION}")

## Use all the *.cpp files we found under this folder for the project Find better way for coomen cpp files
FILE(GLOB SRCS "*.cpp" "*/*.cpp")

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows" )
    SET (project_BIN ${PROJECT_NAME})
else()
    SET (project_BIN ${PROJECT_NAME}.bin)
endif()

get_filename_component(hw_proto "../protos/helloworld.proto" ABSOLUTE)
get_filename_component(hw_proto_path "${hw_proto}" PATH)
#add_library(proto-objects OBJECT "${hw_proto}")

#target_link_libraries(proto-objects PUBLIC protobuf::libprotobuf gRPC::grpc++)

set(PROTO_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/proto-objects.dir/protos")
set(PROTO_IMPORT_DIRS "${hw_proto_path}")

message(STATUS "Using ProtoImport ${PROTO_IMPORT_DIRS}")

#target_include_directories(proto-objects PUBLIC "$<BUILD_INTERFACE:${PROTO_BINARY_DIR}>")
INCLUDE_DIRECTORIES($<BUILD_INTERFACE:${PROTO_BINARY_DIR}> )
INCLUDE_DIRECTORIES(${UDEV_INCLUDE_DIR})

add_executable(${project_BIN} ${SRCS} ${hw_proto} ${easylogging_SRCS})

#protobuf_generate_cpp(
#    TARGET ${project_BIN}
#    IMPORT_DIRS ${PROTO_IMPORT_DIRS}
#    PROTOC_OUT_DIR "${PROTO_BINARY_DIR}")

#protobuf_generate_cpp(
#    TARGET ${project_BIN}
#    LANGUAGE grpc
#    GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
#    PLUGIN "protoc-gen-grpc=\$<TARGET_FILE:gRPC::grpc_cpp_plugin>"
#    IMPORT_DIRS ${PROTO_IMPORT_DIRS}
#    PROTOC_OUT_DIR "${PROTO_BINARY_DIR}")

## Define the executable

target_add_protobuf(${project_BIN} ${hw_proto_path})
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE systemd)
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE protobuf::libprotobuf)
#missing absl::check absl::log
TARGET_LINK_LIBRARIES(${project_BIN} PRIVATE absl::flags absl::flags_parse)
