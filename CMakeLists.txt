cmake_minimum_required(VERSION 3.20)
project(LodeNativeExample VERSION 1.0.0 LANGUAGES CXX)

find_package(Lode CONFIG REQUIRED)

lode_add_native_module(native_example
    SOURCES
        Native/Main.cpp
)

option(LODE_NATIVE_EXAMPLE_WITH_OPENSSL
    "Build the example with the package-local OpenSSL runtime"
    OFF
)

if(LODE_NATIVE_EXAMPLE_WITH_OPENSSL)
    set(OPENSSL_USE_STATIC_LIBS OFF)
    find_package(OpenSSL REQUIRED COMPONENTS Crypto)

    target_compile_definitions(native_example PRIVATE LODE_NATIVE_EXAMPLE_WITH_OPENSSL)
    target_link_libraries(native_example PRIVATE OpenSSL::Crypto)

    if(WIN32)
        if(NOT OPENSSL_ROOT_DIR)
            message(FATAL_ERROR "Set OPENSSL_ROOT_DIR when OpenSSL runtime bundling is enabled")
        endif()

        file(GLOB OPENSSL_RUNTIME_DLLS
            "${OPENSSL_ROOT_DIR}/bin/libcrypto-*.dll"
        )
        if(NOT OPENSSL_RUNTIME_DLLS)
            message(FATAL_ERROR "Could not find the OpenSSL runtime DLL under ${OPENSSL_ROOT_DIR}/bin")
        endif()

        add_custom_command(TARGET native_example POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${OPENSSL_RUNTIME_DLLS}
                "$<TARGET_FILE_DIR:native_example>"
            COMMENT "Bundling OpenSSL runtime beside native_example"
        )
    endif()
endif()

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
