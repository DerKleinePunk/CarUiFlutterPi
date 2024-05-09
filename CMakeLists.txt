cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
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

SET (MAINFOLDER ${PROJECT_SOURCE_DIR})
configure_file("${MAINFOLDER}/src/common/version.hpp.in" "${MAINFOLDER}/src/common/version.hpp")

CHECK_CXX_COMPILER_FLAG("-std=c++17" COMPILER_SUPPORTS_CXX17)
IF(COMPILER_SUPPORTS_CXX17)
   SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
ELSE()
   MESSAGE(FATAL_ERROR "we need c++17 to build")
ENDIF()

IF(CMAKE_COMPILER_IS_GNUCXX)
  SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -DELPP_THREAD_SAFE -DELPP_FEATURE_PERFORMANCE_TRACKING -DELPP_NO_DEFAULT_LOG_FILE -DELPP_STACKTRACE_ON_CRASH -DELPP_DEBUG_ERRORS")
  #-DELPP_STACKTRACE_ON_CRASH only on linux with gcc
ENDIF(CMAKE_COMPILER_IS_GNUCXX)

SET (EXECUTABLE_OUTPUT_PATH "${MAINFOLDER}/bin/${TARGET}")

ADD_SUBDIRECTORY(src/common/easylogging)
ADD_SUBDIRECTORY(src/SimBackend)