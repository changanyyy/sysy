cmake_minimum_required(VERSION 3.24)

set(CMAKE_CXX_COMPILER "clang++")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -Wall -g -pedantic")

project(compiler VERSION 0.1 LANGUAGES CXX)


set(SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_include_directories(compiler PRIVATE
    ${SRC_DIR}/grammar

)


add_subdirectory(
    ${SRC_DIR}/grammar
)



add_executable(
    compiler
    ${SRC_DIR}/main.cpp
)

target_link_libraries(
    compiler
    parser
)


install(
    TARGETS compiler
    RUNTIME DESTINATION bin
)