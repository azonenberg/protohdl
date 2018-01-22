`default_nettype none
`timescale 1ns / 1ps
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

/**
	@file
	@author Andrew D. Zonenberg
	@brief	Core Protocol Buffer parser

	TO DECODE A MESSAGE:
	* Assert "start" for one cycle while asserting "valid", with the first message byte in "din"
	* Assert "valid" for each subsequent message byte on "din"

	TYPE INFO TABLE
	Since protobuf wire format doesn't include any type information, we need a compiled version of the .proto file
	to figure out what to do with new data fields. This is a machine-generated combinatorial block that is attached
	to the "tinfo_*" bus.

	LIMITATIONS:
	* Fixed (defined at synthesis time by parameter) maximum recursion/nesting depth
	* All vector fields must be contiguous.
	  Concatenating two protobuf objects is fine (it's OK to have fields in any order) as long as a vector field only
	  occurs in one or the other.
 */
module ProtobufParser(
	clk,
	start, valid, din,
	tinfo_field_id, tinfo_nest_level, tinfo_field_type, tinfo_is_object, tinfo_is_vector,
	field_valid, field_data, field_id, array_index, nest_level
	);

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// I/O / parameter declarations

	parameter			MAX_NESTING		= 5;				//Maximum number of levels of struct nesting we support
															//This is dependent on the selected message format.
															//TODO: have .proto compiler calculate this

	`include "clog2.vh"
	localparam 			NEST_BITS		= clog2(MAX_NESTING);

	input wire							clk;

	//INPUT DATA BUS
	input wire							start;				//Assert simultaneously with first "valid" input data
	input wire							valid;				//Assert for each input data byte
	input wire[7:0]						din;				//Input data stream

	//TYPE INFO TABLE (combinatorial lookup for now, may change based on timing)
	output reg[32*MAX_NESTING-1:0]		tinfo_field_id;		//Field ID we want to look up
	output reg[NEST_BITS-1:0]			tinfo_nest_level;	//Nesting level we're currently at (0 = top level)
	input wire[4:0]						tinfo_field_type;	//Type of the field
	input wire							tinfo_is_object;	//true if the field is an object (increase nesting)
	input wire							tinfo_is_vector;	//true if the field is a vector (multiple elements)

	//OUTPUT DATA BUS
	output reg							field_valid;		//True if field_data is meaningful

	output reg[63:0]					field_data;			//Data for the current field.
															//Valid bits:
															//double/int64/uint64/sint64/fixed64/sfixed64:	63:0
															//float/int32/uint32/sint32/fixed32/sfixed32:	31:0
															//enum											31:0
															//string/bytes (1 byte per clock)				7:0
															//bool											0:0
	
	output reg[32*MAX_NESTING-1:0]		field_id;			//Array of field IDs, concatenated. 31:0 is the top level.
															//Example: foo(=3).bar(=1) would be represented as
															//31:0  = 32'h3
															//63:32 = 32'h1

	output reg[32*MAX_NESTING-1:0]		array_index;		//Array of array indexes, concatenated.
															//Example: foo[2].bar[4] would be represented as
															//31:0  = 32'h2
															//63:32 = 32'h4
															
	output reg[NEST_BITS-1:0]			nest_level;			//Number of nesting levels valid in field_id / array_index

endmodule
