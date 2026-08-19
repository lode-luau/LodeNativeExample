cmake_minimum_required(VERSION 3.20)
project(LodeNativeExample VERSION 1.0.0 LANGUAGES CXX)

find_package(Lode CONFIG REQUIRED)

lode_add_native_module(native_example
    SOURCES
        Native/Main.cpp
)

include(CTest)

set(LODE_RUNTIME "" CACHE FILEPATH "Path to the matching Lode executable")

if(BUILD_TESTING)
    if(NOT LODE_RUNTIME)
        message(FATAL_ERROR "Set LODE_RUNTIME to the Debug or Release lode executable")
    endif()

    add_test(
        NAME native_example_tests
        COMMAND "${LODE_RUNTIME}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/run.luau"
    )
    set_tests_properties(native_example_tests PROPERTIES
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    )
endif()
