`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:14:03 05/10/2017 
// Design Name: 
// Module Name:    M_decoder 
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
module M_decoder( input [31:0] inst,
						output Rtype, Itype, shift, MemAccess, branch,
								 addr, subr, andr, orr, sltr, norr, xorr,
								 srl, sll, j, jr, jal, jalr, beq, bne,
								 addi, andi, ori, slti, xori, lui, lw, sw
    );
	 
	 wire [5:0] op, func;
	 assign op = inst[31:26];
	 assign func = inst[5:0];
	 
	 assign j = (op == 6'd2) ? 1 : 0;
	 assign jal = (op ==  6'd3) ? 1 : 0;
	 assign beq = (op == 6'd4) ? 1 : 0;
	 assign bne = (op == 6'd5) ? 1 : 0;
	 assign addi = (op == 6'd8) ? 1 : 0;
	 assign slti = (op == 6'd10) ? 1 : 0;
	 assign andi = (op == 6'd12) ? 1 : 0;
	 assign ori = (op == 6'd13) ? 1 : 0;
	 assign xori = (op == 6'd14) ? 1 : 0;
	 assign lui = (op == 6'd15) ? 1 : 0;
	 assign lw = (op == 6'd35) ? 1 : 0;
	 assign sw = (op == 6'd43) ? 1 : 0;
	 assign sll = (op == 6'd0 && func == 6'd0) ? 1 : 0;
	 assign srl = (op == 6'd0 && func == 6'd2) ? 1 : 0;
	 assign jr = (op == 6'd0 && func == 6'd8) ? 1 : 0;
	 assign jalr = (op == 6'd0 && func == 6'd9) ? 1 : 0;
	 assign addr = (op == 6'd0 && func == 6'd32) ? 1 : 0;
	 assign subr = (op == 6'd0 && func == 6'd34) ? 1 : 0;
	 assign andr = (op == 6'd0 && func == 6'd36) ? 1 : 0;
	 assign orr = (op == 6'd0 && func == 6'd37) ? 1 : 0;
	 assign xorr = (op == 6'd0 && func == 6'd38) ? 1 : 0;
	 assign norr = (op == 6'd0 && func == 6'd39) ? 1 : 0;
	 assign sltr = (op == 6'd0 && func == 6'd42) ? 1 : 0;
	 
	 assign MemAccess = (op == 6'd35 || op == 6'd43) ? 1 : 0;
	 assign shift = (op == 6'd0 && (func == 6'd0 || func == 6'd2) ) ? 1 : 0;
	 assign branch = (op == 6'd4 || op == 6'd5) ? 1 : 0;
	 assign Rtype = (op == 6'd0 && func <= 6'd42 && func >= 6'd32) ? 1 : 0;
	 assign Itype = (op <= 6'd14 && op >= 6'd8) ? 1 : 0;
	 
endmodule
