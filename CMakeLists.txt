cmake_minimum_required(VERSION 3.27)
project(luna)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(FetchContent)

set(BUILD_SHARED_LIBS OFF)
set(OPENSSL_USE_STATIC_LIBS ON)
set(ZLIB_USE_STATIC_LIBS ON)
FetchContent_Declare(
    cpr
    GIT_REPOSITORY https://github.com/libcpr/cpr.git
    GIT_TAG 3b15fa82ea74739b574d705fea44959b58142eb8
)

FetchContent_Declare(
    jerryscript
    GIT_REPOSITORY https://github.com/luna-lnx/jerryscript.git
    GIT_TAG 075052c71c5f08daccbd0c27b3b05b2e4f68723d
)

FetchContent_MakeAvailable(cpr jerryscript)

include_directories(include)

file(GLOB SOURCES "src/*.cpp")
message(Sources ${SOURCES})
add_executable(luna ${SOURCES})

target_link_libraries(luna PRIVATE cpr c++ c++abi)
target_link_libraries(luna PRIVATE jerry-core jerry-port)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Os -static")
set(CMAKE_EXE_LINKER_FLAGS "-flto=full")
