add_executable(protoc-gen-verilog
	VerilogGenerator.cpp

	main.cpp
)

target_link_libraries(protoc-gen-verilog
	log protobuf protoc)

#force static analysis to rerun
#TODO: automate this for every target?
add_dependencies(protoc-gen-verilog analysis)

# Installation config
install(TARGETS protoc-gen-verilog
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib)

