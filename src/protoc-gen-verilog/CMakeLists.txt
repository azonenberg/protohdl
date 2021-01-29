add_executable(protoc-gen-verilog
	VerilogGenerator.cpp

	main.cpp
)

set(CMAKE_C_FLAGS          "${CMAKE_C_FLAGS}          -I$ENV{CONDA_PREFIX}/include -L$ENV{CONDA_PREFIX}/lib")
set(CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS}        -I$ENV{CONDA_PREFIX}/include")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L$ENV{CONDA_PREFIX}/lib")

target_link_libraries(protoc-gen-verilog
	log protoc protobuf)

#force static analysis to rerun
#TODO: automate this for every target?
add_dependencies(protoc-gen-verilog analysis)

# Installation config
install(TARGETS protoc-gen-verilog
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib)

