add_executable(protohdlc
	ProtoFileParser.cpp

	main.cpp
)

target_link_libraries(protohdlc
	log)

#force static analysis to rerun
#TODO: automate this for every target?
add_dependencies(protohdlc analysis)

# Installation config
install(TARGETS protohdlc
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib)

