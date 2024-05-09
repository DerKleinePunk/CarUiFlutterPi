message(STATUS "working on easylogging dir")

FILE (GLOB easylogging_SRCS "*.cpp" "*.cxx" "*.cc" "*.c")

set(easylogging_SRCS ${easylogging_SRCS} PARENT_SCOPE)