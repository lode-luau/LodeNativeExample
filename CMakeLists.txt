cmake_minimum_required(VERSION 3.20)
project(LodeNativeExample VERSION 1.0.0 LANGUAGES CXX)

find_package(Lode CONFIG REQUIRED)

lode_add_native_module(native_example
    SOURCES
        Native/Main.cpp
)
