cmake_minimum_required(VERSION 3.0)
project(protohdl)

set( EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/bin)
set( LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/bin)

set(EXTRA_WARNINGS "-Wcast-align -Winit-self -Wmissing-declarations")
set(EXTRA_WARNINGS "${EXTRA_WARNINGS} -Wswitch -Wwrite-strings ")
set( CMAKE_CXX_FLAGS "-Wall -Wextra ${EXTRA_WARNINGS} -std=c++11 -fPIC -shared-libgcc -ggdb -O2")
set( CMAKE_CXX_FLAGS_DEBUG "-fsanitize=address")
set( CMAKE_LINK_FLAGS "-ggdb")

#Search for cppcheck
find_program(CPPCHECK cppcheck)
if(NOT CPPCHECK)
	message(FATAL_ERROR "cppcheck required but not found.")
endif()

#Custom target to run static analysis
add_custom_target(
	analysis
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	COMMAND cppcheck . --enable=style,performance,portability,missingInclude --force -I ${CMAKE_BINARY_DIR}/protobufs --suppress=missingIncludeSystem -q --check-config)

add_subdirectory(src)

# TODO: CPack stuff
