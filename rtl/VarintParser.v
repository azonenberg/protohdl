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
	@brief	Parser for Protobuf base-128 varint format

	Format reference: https://developers.google.com/protocol-buffers/docs/encoding#varints

	To begin parsing a new varint:
		* Assert "start" and "valid", set "dsign" appropriately (1=signed, 0=unsigned),
		  then feed the first data byte to "din".
		* Provide subsequent data bytes at any time (need not be consecutive clocks) with "valid" asserted.
		  Do not change "dsign" during parsing.

	When parsing is complete, "done" goes high and "dout" is updated combinatorially.
	If "error" goes high at any time an invalid encoding was provided and the output should be ignored.
 */
module VarintParser(
	input wire			clk,

	input wire			start,
	input wire			valid,
	input wire[7:0]		din,
	input wire			dsign,

	output wire[63:0]	dout,
	output wire			done,
	output wire			error
	);

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//

	reg					active_ff		= 0;
	reg[63:0]			data_temp_ff	= 0;
	reg[63:0]			data_temp		= 0;
	reg[3:0]			bytecount		= 0;

	//Combinatorial "parsing active" flag
	wire				active		= active_ff || start;

	//We're done parsing a varint if we get a new byte with MSB clear
	assign				done		= active && valid && !din[7];

	//Output data updates when we finish parsing and is held constant otherwise to aovid needless toggling
	wire[63:0]			dout_unsigned	= done ? data_temp : 0;

	//Decode "zigzag" sign coding
	wire[63:0]			dout_signed		= dout_unsigned[0] ? ~(dout_unsigned >> 1) : (dout_unsigned >> 1);

	//Mux signed/unsigned output
	assign				dout			= dsign ? dout_signed : dout_unsigned;

	//If we got ten bytes of data and still aren't done, that's an error
	//since protobuf varints can't be >64 bits long
	assign				error		= (bytecount == 10) && active;

	//Update the temporary data combinatorially
	always @(*) begin

		//Default: copy last cycle's state
		data_temp	<= data_temp_ff;

		//New data? Need to save it!
		if(valid) begin
			case(bytecount)
				0:	data_temp[0*7 +: 7]	<= din[6:0];
				1:	data_temp[1*7 +: 7]	<= din[6:0];
				2:	data_temp[2*7 +: 7]	<= din[6:0];
				3:	data_temp[3*7 +: 7]	<= din[6:0];
				4:	data_temp[4*7 +: 7]	<= din[6:0];
				5:	data_temp[5*7 +: 7]	<= din[6:0];
				6:	data_temp[6*7 +: 7]	<= din[6:0];
				7:	data_temp[7*7 +: 7]	<= din[6:0];
				8:	data_temp[8*7 +: 7]	<= din[6:0];
				9:	data_temp[63]		<= din[0];		//special case for last byte (only one valid bit)
			endcase
		end
		
	end

	always @(posedge clk) begin

		//Active flag is set combinatorially. Clear it sequentially when we finish.
		active_ff		<= active && !done;

		//New varint? We're now starting at the beginning of the message
		if(start)
			bytecount	<= 1;

		//Bump byte count as new data arrives
		else if(valid)
			bytecount	<= bytecount + 1'h1;

		//Clear internal state on reset
		if(done) begin
			bytecount		<= 0;
			data_temp_ff	<= 0;
		end

		//Save temporary state during parsing
		else
			data_temp_ff	<= data_temp;
	
	end

endmodule
