# Example:
# In CMake:
#     add_library(tezt tezt.cpp)
#     target_add_protobuf(tezt my.proto)
# Then, in the source code:
#     #include <my.pb.h>
#     #include <my.grpc.pb.h>
function(target_add_protobuf target)
if(NOT TARGET ${target})
    message(FATAL_ERROR "Target ${target} doesn't exist")
endif()
if(NOT ARGN)
    message(SEND_ERROR "Error: PROTOBUF_GENERATE_GRPC_CPP() called without any proto files")
    return()
endif()

set(_protobuf_include_path -I . -I ${_gRPC_PROTOBUF_WELLKNOWN_INCLUDE_DIR})
foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    file(RELATIVE_PATH REL_FIL ${CMAKE_CURRENT_SOURCE_DIR} ${ABS_FIL})
    get_filename_component(REL_DIR ${REL_FIL} DIRECTORY)
    if(NOT REL_DIR)
        set(RELFIL_WE "${FIL_WE}")
    else()
        set(RELFIL_WE "${REL_DIR}/${FIL_WE}")
    endif()

    if(NOT TARGET grpc_cpp_plugin)
        message(FATAL_ERROR "Can not find target grpc_cpp_plugin")
    endif()
    set(_gRPC_CPP_PLUGIN $<TARGET_FILE:grpc_cpp_plugin>)

    add_custom_command(
    OUTPUT  "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.grpc.pb.cc"
            "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.grpc.pb.h"
            "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}_mock.grpc.pb.h"
            "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.pb.cc"
            "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.pb.h"
    COMMAND ${_gRPC_PROTOBUF_PROTOC_EXECUTABLE}
    ARGS --grpc_out=generate_mock_code=true:${_gRPC_PROTO_GENS_DIR}
        --cpp_out=${_gRPC_PROTO_GENS_DIR}
        --plugin=protoc-gen-grpc=${_gRPC_CPP_PLUGIN}
        ${_protobuf_include_path}
        ${REL_FIL}
    DEPENDS ${ABS_FIL} ${_gRPC_PROTOBUF_PROTOC} ${_gRPC_CPP_PLUGIN}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running gRPC C++ protocol buffer compiler on ${FIL}"
    VERBATIM)

    target_sources(${target} PRIVATE
        "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.grpc.pb.cc"
        "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.grpc.pb.h"
        "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}_mock.grpc.pb.h"
        "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.pb.cc"
        "${_gRPC_PROTO_GENS_DIR}/${RELFIL_WE}.pb.h"
    )
    target_include_directories(${target} PRIVATE
        $<BUILD_INTERFACE:${_gRPC_PROTO_GENS_DIR}>
        $<BUILD_INTERFACE:${_gRPC_PROTOBUF_WELLKNOWN_INCLUDE_DIR}>
        $<BUILD_INTERFACE:${grpc_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${grpc_SOURCE_DIR}/third_party/abseil-cpp>
    )
endforeach()
endfunction()