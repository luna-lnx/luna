cmake_minimum_required(VERSION 3.27)
project(luna)

set(CMAKE_CXX_STANDARD 17)

include(FetchContent)
FetchContent_Declare(
        spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog
)
FetchContent_MakeAvailable(spdlog)

add_executable(luna src/main.cpp)
target_link_libraries(luna spdlog::spdlog_header_only)

