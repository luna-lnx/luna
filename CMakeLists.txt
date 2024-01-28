cmake_minimum_required(VERSION 3.27)
project(luna)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(BUILD_SHARED_LIBS False)

add_subdirectory(lib/cpr)

include_directories(include)

file(GLOB SOURCES "src/*.cpp")
message(Sources ${SOURCES})
add_executable(luna ${SOURCES})

target_link_libraries(luna cpr)
target_link_options(luna PRIVATE -s)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Oz -static")
set_target_properties(luna PROPERTIES
    LINK_SEARCH_START_STATIC 1
    LINK_SEARCH_END_STATIC 1
)