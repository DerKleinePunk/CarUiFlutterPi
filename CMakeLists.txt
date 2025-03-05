cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
# Main CMake

#
# Debugging Options
#
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    SET (CMAKE_VERBOSE_MAKEFILE 1) # Use 1 for debugging, 0 for release
ENDIF()

#Build Cmake Environment
SET(PKG_CONFIG_USE_CMAKE_PREFIX_PATH TRUE)
find_package(PkgConfig)

include(CheckCXXCompilerFlag)
include(ExternalProject)
include(CheckTypeSize)
include(CheckIncludeFiles)

## Use the variable PROJECT_NAME for changing the target name
SET ( PROJECT_NAME "CarUiFlutterPi" )

file(STRINGS "RELEASE_VERSION.txt" RELEASE_VERSION)
SET(RELEASE_VERSION  "${RELEASE_VERSION}" CACHE INTERNAL "RELEASE_VERSION")

PROJECT(${PROJECT_NAME} VERSION "${RELEASE_VERSION}" ) ## Not Able to use CXX because C files are not compiled
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED On)

SET (MAINFOLDER ${PROJECT_SOURCE_DIR})
configure_file("${MAINFOLDER}/src/common/version.hpp.in" "${MAINFOLDER}/src/common/version.hpp")

IF(CMAKE_COMPILER_IS_GNUCXX)
  SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -DELPP_THREAD_SAFE -DELPP_FEATURE_PERFORMANCE_TRACKING -DELPP_NO_DEFAULT_LOG_FILE -DELPP_STACKTRACE_ON_CRASH -DELPP_DEBUG_ERRORS")
  #-DELPP_STACKTRACE_ON_CRASH only on linux with gcc
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

SET (EXECUTABLE_OUTPUT_PATH "${MAINFOLDER}/bin/${TARGET}")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")

# https://bugs.launchpad.net/ubuntu/+source/grpc/+bug/1935709 missing files
find_package(udev REQUIRED)

#SET (GRPC_FETCHCONTENT TRUE)
#SET (GRPC_VERSION_TAG v1.70.0)
#SET (protobuf_INSTALL OFF)
#SET (utf8_range_ENABLE_INSTALL OFF)
#SET (protobuf_BUILD_TESTS OFF)
#SET (protobuf_BUILD_CONFORMANCE OFF)
#SET (protobuf_BUILD_EXAMPLES OFF)
#SET (gRPC_BUILD_TESTS OFF)
#SET (gRPC_BUILD_CODEGEN ON) # for grpc_cpp_plugin
#SET (gRPC_BUILD_GRPC_CPP_PLUGIN ON) # we want to use only C++ plugin
#SET (gRPC_BUILD_CSHARP_EXT OFF)
#SET (gRPC_BUILD_GRPC_CSHARP_PLUGIN OFF)
#SET (gRPC_BUILD_GRPC_NODE_PLUGIN OFF)
#SET (gRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN OFF)
#SET (gRPC_BUILD_GRPC_PHP_PLUGIN OFF)
#SET (gRPC_BUILD_GRPC_PYTHON_PLUGIN OFF)
#SET (gRPC_BUILD_GRPC_RUBY_PLUGIN OFF)

#include(GPRCCommon)

option(USE_SYSTEM_GRPC "Use system installed gRPC" ON)
if(USE_SYSTEM_GRPC)
  # Find system-installed gRPC
  find_package(gRPC CONFIG REQUIRED)
  find_package(Protobuf REQUIRED)
  find_package(absl REQUIRED)
else()
  SET (ABSL_BUILD_TESTING OFF)
  SET (GRPC_FETCHCONTENT TRUE)
  SET (GRPC_VERSION_TAG v1.70.0)
  SET (protobuf_INSTALL OFF)
  SET (utf8_range_ENABLE_INSTALL OFF)
  set (protobuf_BUILD_TESTS OFF)
  set (protobuf_BUILD_CONFORMANCE OFF)
  set (protobuf_BUILD_EXAMPLES OFF)
  SET (gRPC_BUILD_TESTS OFF)
  SET (gRPC_BUILD_CODEGEN ON) # for grpc_cpp_plugin
  SET (gRPC_BUILD_GRPC_CPP_PLUGIN ON) # we want to use only C++ plugin
  SET (gRPC_BUILD_CSHARP_EXT OFF)
  SET (gRPC_BUILD_GRPC_CSHARP_PLUGIN OFF)
  SET (gRPC_BUILD_GRPC_NODE_PLUGIN OFF)
  SET (gRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN OFF)
  SET (gRPC_BUILD_GRPC_PHP_PLUGIN OFF)
  SET (gRPC_BUILD_GRPC_PYTHON_PLUGIN OFF)
  SET (gRPC_BUILD_GRPC_RUBY_PLUGIN OFF)

  include(GPRCCommon)

  list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/build/_deps/grpc-build")

  message(STATUS "${CMAKE_MODULE_PATH}")
  find_package(gRPC CONFIG REQUIRED)
endif()


include(TargetProtoBuf)
message(STATUS "Using protobuf version ${Protobuf_VERSION}")
message(STATUS "Using gRPC version ${gRPC_VERSION}")

set(_GRPC_GRPCPP gRPC::grpc++)
if(CMAKE_CROSSCOMPILING)
  find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
else()
  set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
endif()

message(STATUS "Using gRPC EXECUTABLE ${_GRPC_CPP_PLUGIN_EXECUTABLE}")

ADD_SUBDIRECTORY(src/common/easylogging)
ADD_SUBDIRECTORY(src/SimBackend)
