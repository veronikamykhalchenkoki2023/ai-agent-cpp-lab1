cmake_minimum_required(VERSION 3.16)
project(hello LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(FetchContent)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

add_library(math_utils src/math_utils.cpp)
target_include_directories(math_utils PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

add_executable(hello src/main.cpp)
target_link_libraries(hello PRIVATE math_utils)

add_executable(basic_addition_test tests/BasicAdditionTest.cpp)
target_link_libraries(basic_addition_test PRIVATE math_utils gtest_main)

enable_testing()
add_test(NAME BasicAddition COMMAND basic_addition_test)
