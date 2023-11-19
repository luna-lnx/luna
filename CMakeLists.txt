cmake_minimum_required(VERSION 3.27)
project(luna)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_subdirectory(lib/spdlog)
add_subdirectory(lib/cpr)

include_directories(include)

file(GLOB SOURCES "src/*.cpp")
add_executable(luna ${SOURCES})

target_link_libraries(luna spdlog cpr)
target_link_options(luna PRIVATE -s)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Oz -flto")
