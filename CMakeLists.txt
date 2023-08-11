cmake_minimum_required(VERSION 3.10)
project(luna C)
add_subdirectory(lib/curl)
set(SOURCES
    luna.c
    trim.c
    update.c
)
add_executable(luna ${SOURCES})
target_link_libraries(luna CURL::libcurl)