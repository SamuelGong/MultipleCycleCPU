`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:30:59 05/10/2017 
// Design Name: 
// Module Name:    MUX8T1_32 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module  MUX8T1_32( input [2:0]s,
						 input [31:0]I0,
						 input [31:0]I1,
						 input [31:0]I2,
						 input [31:0]I3,
						 input [31:0]I4,
						 input [31:0]I5,
						 input [31:0]I6,
						 input [31:0]I7,			 
						 output reg [31:0]o
						 );
		always @ *			 
			case(s)
				3'd0: o = I0;
				3'd1: o = I1;
				3'd2: o = I2;
				3'd3: o = I3;
				3'd4: o = I4;
				3'd5: o = I5;
				3'd6: o = I6;
				3'd7: o = I7;
				default : ;
			endcase	
			
endmodule

