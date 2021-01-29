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
	@brief	Test case for VarintParser
 */
module VarintParser_sim();

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 100 MHz clock and power-on reset

	reg		ready	= 0;

	reg		clk		= 0;

	initial begin
		$monitor("ready=%b, clk=%b, start=%b, valid=%b, din=%b, dsign=%b, dout=%b, done=%b, error=%b", ready, clk, start, valid, din, dsign, dout, done, error);
		$dumpfile("build/VarintParser_sim_300.vcd");
		$dumpvars(0, VarintParser_sim);

		#100;
		ready = 1;
	end

	always begin
		#5;
		clk = 0;
		#5;
		clk = ready;
	end

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// The DUT

	reg			start	= 0;
	reg			valid	= 0;
	reg[7:0]	din 	= 0;
	reg			dsign	= 0;

	wire[63:0]	dout;
	wire		done;
	wire		error;

	VarintParser dut(
		.clk(clk),

		.start(start),
		.valid(valid),
		.din(din),
		.dsign(dsign),

		.dout(dout),
		.done(done),
		.error(error)
	);

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Testbench

	reg[7:0] state	= 0;

	always @(posedge clk) begin

		start	<= 0;
		valid	<= 0;
		dsign	<= 0;

		case(state)

			// test case #01: AC 02 -> 'd300
			0: begin

				start		<= 1;
				valid		<= 1;
				din			<= 8'hac;

				state		<= 1;
			end
			1: begin
				valid		<= 1;
				din			<= 8'h02;
				state		<= 2;
			end

			// done
			2: begin

				if(!done || error || ($signed(dout) != 300) ) begin
					$display("FAIL: signed test case 01 failed");
					$finish;
				end

				$display("PASS");
				$finish;
			end

		endcase

	end

endmodule
