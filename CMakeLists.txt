cmake_minimum_required(VERSION 3.27)
project(luna)

set(CMAKE_CXX_STANDARD 17)
add_subdirectory(lib/spdlog)

add_executable(luna src/main.cpp)
target_link_libraries(luna spdlog)

