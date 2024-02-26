cmake_minimum_required(VERSION 3.27)
project(luna)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#set(BUILD_SHARED_LIBS False)
#set(OPENSSL_USE_STATIC_LIBS ON)

add_subdirectory(lib/cpr)

include_directories(include)

file(GLOB SOURCES "src/*.cpp")
message(Sources ${SOURCES})
add_executable(luna ${SOURCES})

target_link_libraries(luna cpr)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Oz -s -static")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Oz")