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

localparam FIELD_TYPE_DOUBLE	= 5'h00;
localparam FIELD_TYPE_FLOAT		= 5'h01;
localparam FIELD_TYPE_INT32		= 5'h02;	//signed varint optimized for positive numbers
localparam FIELD_TYPE_INT64		= 5'h03;	//signed varint optimized for positive numbers
localparam FIELD_TYPE_UINT32	= 5'h04;	//unsigned varint
localparam FIELD_TYPE_UINT64	= 5'h05;	//unsigned varint
localparam FIELD_TYPE_SINT32	= 5'h06;	//signed varint optimized for positive/negative numbers
localparam FIELD_TYPE_SINT64	= 5'h07;	//signed varint optimized for positive/negative numbers
localparam FIELD_TYPE_FIXED32	= 5'h08;	//fixed width unsigned int, no varint coding
localparam FIELD_TYPE_FIXED64	= 5'h09;	//fixed width unsigned int, no varint coding
localparam FIELD_TYPE_SFIXED32	= 5'h0a;	//fixed width signed int, no varint coding
localparam FIELD_TYPE_SFIXED64	= 5'h0b;	//fixed width signed int, no varint coding
localparam FIELD_TYPE_BOOL		= 5'h0c;
localparam FIELD_TYPE_STRING	= 5'h0d;	//ascii string (UTF-8 or ascii)
localparam FIELD_TYPE_BYTES		= 5'h0e;	//arbitrary byte array
localparam FIELD_TYPE_ENUM		= 5'h0f;
localparam FIELD_TYPE_OBJECT	= 5'h10;
