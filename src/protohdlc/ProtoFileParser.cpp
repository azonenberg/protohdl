/***********************************************************************************************************************
*                                                                                                                      *
* PROTOHDL v0.1                                                                                                        *
*                                                                                                                      *
* Copyright (c) 2018 Andrew D. Zonenberg                                                                               *
* All rights reserved.                                                                                                 *
*                                                                                                                      *
* Redistribution and use in source and binary forms, with or without modification, are permitted provided that the     *
* following conditions are met:                                                                                        *
*                                                                                                                      *
*    * Redistributions of source code must retain the above copyright notice, this list of conditions, and the         *
*      following disclaimer.                                                                                           *
*                                                                                                                      *
*    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the       *
*      following disclaimer in the documentation and/or other materials provided with the distribution.                *
*                                                                                                                      *
*    * Neither the name of the author nor the names of any contributors may be used to endorse or promote products     *
*      derived from this software without specific prior written permission.                                           *
*                                                                                                                      *
* THIS SOFTWARE IS PROVIDED BY THE AUTHORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   *
* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL *
* THE AUTHORS BE HELD LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES        *
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR       *
* BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT *
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE       *
* POSSIBILITY OF SUCH DAMAGE.                                                                                          *
*                                                                                                                      *
***********************************************************************************************************************/

#include "protohdlc.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Construction / destruction

ProtoFileParser::ProtoFileParser(string fname)
{
	LoadProtoFile(fname);
}

ProtoFileParser::~ProtoFileParser()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Core parsing logic

bool ProtoFileParser::LoadProtoFile(string fname)
{
	//Open it
	LogDebug("Compiling .proto file %s\n", fname.c_str());
	LogIndenter li;

	FILE* fp = fopen(fname.c_str(), "r");
	if(!fp)
	{
		LogError("fail to open %s\n", fname.c_str());
		return false;
	}

	//Read top-level blocks
	bool saw_syntax = false;
	bool err = false;
	while(!feof(fp))
	{
		//Read the keyword
		char tmp[1024];
		if(1 != fscanf(fp, " %1023s", tmp))
		{
			LogError("Unexpected end of file found\n");
			err = true;
			break;
		}
		string key(tmp);

		//Comment? Read to the end of the line and discard
		if(strstr(tmp, "//") != NULL)
		{
			LogTrace("Got comment\n");
			while(fgetc(fp) != '\n')
			{}

			continue;
		}

		//Syntax declaration - must be "proto3"
		if(key == "syntax")
		{
			saw_syntax = true;

			char syntax[128];
			if(1 != fscanf(fp, " = \"%127[^\"]\";", syntax))
			{
				LogError("Malformed \"syntax\" declaration\n");
				err = true;
				break;
			}

			string ssyntax(syntax);
			if(ssyntax != "proto3")
			{
				LogError("Invalid syntax \"%s\", expected \"proto3\"\n", syntax);
				err = true;
				break;
			}
			LogDebug("Valid syntax declaration\n");
		}

		//Anything else must not happen until we have syntax = proto3
		else if(!saw_syntax)
		{
			LogError("Need syntax = \"proto3\" before any other declarations (proto2 syntax not supported)\n");
			err = true;
			break;
		}

		//We have a message type! Parse it
		else if(key == "message")
		{
			if(!LoadMessageBlock(fp))
			{
				err = true;
				break;
			}
		}

		//Import a new .proto file
		else if(key == "import")
		{
			LogError("Import not implemented yet\n");
			err = true;
			break;
		}

		//Configuration option
		else if(key == "option")
		{
			LogError("Option not implemented yet\n");
			err = true;
			break;
		}

		//Scoping
		else if(key == "package")
		{
			LogError("Package not implemented yet\n");
			err = true;
			break;
		}

		//Enum
		else if(key == "enum")
		{
			LogError("Top-level enum not implemented yet\n");
			err = true;
			break;
		}

		//Service
		else if(key == "service")
		{
			LogError("service not implemented yet\n");
			err = true;
			break;
		}

		//Empty statement (ignore silently)
		else if(key == ";")
		{
		}

		//If we get here, we have a problem
		else
		{
			LogError("Unrecognized keyword \"%s\"\n", key.c_str());
			err = true;
			break;
		}


	}

	fclose(fp);
	return err;
}

bool ProtoFileParser::LoadMessageBlock(FILE* fp)
{
	//Read the message type
	char mtype[128];
	if(1 != fscanf(fp, " %127[^ {\n] {", mtype))
	{
		LogError("Malformed message block identifier\n");
		return false;
	}

	//Debug logging
	LogDebug("Processing message \"%s\"\n", mtype);
	LogIndenter li;

	while(!feof(fp))
	{
		//Ignore comments before the next declaration
		if(!EatComments(fp))
			return false;
		if(feof(fp))
			break;

		//If we got a '}', we're done with this block
		char tmp = fgetc(fp);
		if(tmp == '}')
			return true;
		else
			ungetc(tmp, fp);

		//Read the field type
		char fieldtype[128];
		if(1 != fscanf(fp, " %127s ", fieldtype))
		{
			LogError("Malformed message type\n");
			return false;
		}
		if(!EatComments(fp))
			return false;
		string stype(fieldtype);

		//If the field type is "enum" then we have an inline enum
		if(stype == "enum")
		{
			LogError("Inline enum not supported\n");
			return false;
			continue;
		}

		//Read the field name
		char fieldname[128];
		if(1 != fscanf(fp, "%127[^ \t=] = ", fieldname))
		{
			LogError("Malformed field name\n");
			return false;
		}

		if(!EatComments(fp))
			return false;

		//Read the field value
		int fieldid;
		if(1 != fscanf(fp, "%d ;", &fieldid))
		{
			LogError("Malformed field ID (type=%s, name=%s)\n", fieldtype, fieldname);
			return false;
		}

		//TODO: verify the type is valid

		LogDebug("Field %s is of type %s (id = %d)\n", fieldname, fieldtype, fieldid);

		//TODO: save this
	}

	return true;
}

/**
	@brief Discard leading whitespace
 */
bool ProtoFileParser::EatSpaces(FILE* fp)
{
	char tmp = fgetc(fp);
	while(isspace(tmp))
		tmp = fgetc(fp);
	ungetc(tmp, fp);

	return true;
}

/**
	@brief Discard comments
 */
bool ProtoFileParser::EatComments(FILE* fp)
{
	if(!EatSpaces(fp))
		return false;

	//Look for comments and discard them
	int tmp = fgetc(fp);
	if(tmp == '/')
	{
		//Next character should be a / as well
		tmp = fgetc(fp);
		if(tmp == '/')
		{
			while(tmp != '\n')
				tmp = fgetc(fp);
		}
		else
		{
			LogError("Malformed comment\n");
			return false;
		}
	}
	else
		ungetc(tmp, fp);

	if(!EatSpaces(fp))
		return false;

	return true;
}
