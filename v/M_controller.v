`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:30:49 05/10/2017 
// Design Name: 
// Module Name:    M_controller 
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
module M_controller(	input	[31:0] inst,
							input clk, rst,
							output reg PCWriteCond,	PCWrite,	IorD, 	MemRead,
										MemWrite, 		IRWrite,	ext,
										RegWrite,
							output wire beq_o,		bne_o,
							output reg [1:0] MemToReg,	RegDst,	ALUsrcA, PCsrc,
							output reg [2:0] ALUsrcB,
							output reg [3:0] ALUop,
							output [4:0] State_o
    );
	 
	 reg [4:0] state;
	 assign State_o = state;
	 
	 wire Rtype, Itype, shift, MemAccess, branch;
	 wire addr, subr, andr, orr, sltr, norr, xorr,
	      srl, sll, j, jr, jal, jalr,
			addi, andi, ori, slti, xori, lui, lw, sw;
	 M_decoder decoder( 	.inst(inst),
								.Rtype(Rtype), .Itype(Itype), .shift(shift), .MemAccess(MemAccess),
								.branch(branch), .addr(addr), .subr(subr), .andr(andr), .orr(orr),
								.sltr(sltr), .norr(norr), .xorr(xorr), .srl(srl), .sll(sll), .j(j),
								.jr(jr), .jal(jal), .jalr(jalr), .addi(addi), .andi(andi), 
								.beq(beq), .bne(bne),
								.ori(ori), .slti(slti), .xori(xori), .lui(lui), .lw(lw), .sw(sw));
								
	assign beq_o = beq;
	assign bne_o = bne;
	 
	 always @ (posedge clk or posedge rst) begin
	     if(rst) begin
		      state <= 5'd31;
		  end
		  else begin
		      case(state)
				   // instruction fetch
					5'd31: begin
								PCWriteCond <= 1'd0;
								PCWrite <= 1'd1;
								MemWrite <= 1'd0;
								MemRead <= 1'd1;
								IRWrite <= 1'd1;
								RegWrite <= 1'd0;
								PCsrc <= 2'd0;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								ALUsrcA <= 2'd0;
								ALUsrcB <= 3'd1;
								ALUop <= 4'd2;
								IorD <= 1'd0;
								ext <= 1'd0;
								state <= 5'd0;
							end
					// waiting state
					5'd0: begin
								PCWrite <= 1'd0;
								IRWrite <= 1'd0;
								ALUsrcB <= 3'd3;
								ALUop <= 4'd2;
								ext <= 1'd1;
								state <= 5'd1;
							 end
					// inst dec / reg fetch
					5'd1: begin
								if(MemAccess) begin
									state <= 5'd2;
									ALUsrcA <= 2'd1;
									ALUsrcB <= 3'd2;
									ALUop <= 4'd2;
									ext <= 1'd1;
									end
								else if(lui) begin
									state <= 5'd13;
									ALUsrcA <= 2'd3;
									ALUsrcB <= 3'd5;
									ALUop <= 4'd8;
									end
								else if(Rtype) begin
									state <= 5'd6;
									ALUsrcA <= 2'd1;
									ALUsrcB <= 3'd0;
									if(addr)
										ALUop <= 4'd2;
									else if(subr)
										ALUop <= 4'd6;
									else if(andr)
										ALUop <= 4'd0;
									else if(orr)
										ALUop <= 4'd1;
									else if(xorr)
										ALUop <= 4'd3;
									else if(norr)
										ALUop <= 4'd4;
									else if(sltr)
										ALUop <= 4'd7;
									end
								else if(shift) begin
									state <= 5'd12;
									ALUsrcA <= 2'd2;
									ALUsrcB <= 3'd4;
									if(sll)
										ALUop <= 4'd8;
									else if(srl)
										ALUop <= 4'd5;
									end
								else if(Itype) begin
									state <= 5'd10;
									ALUsrcA <= 2'd1;
									ALUsrcB <= 3'd2;
									if(addi)
										ALUop <= 4'd2;
									else if(slti)
										ALUop <= 4'd7;
									else if(andi)
										ALUop <= 4'd0;
									else if(ori)
										ALUop <= 4'd1;
									else if(xori)
										ALUop <= 4'd3;
									if(addi || slti)
										ext <= 1'd1;
									else if(andi || ori || xori)
										ext <= 1'd0;
									end
								else if(branch) begin
									state <= 5'd8;
									PCsrc <= 2'd1;
									ALUsrcA <= 2'd1;
									ALUsrcB <= 3'd0;
									ALUop <= 4'd6;
									PCWriteCond <= 1'd1;
									end
								else if(j || jal) begin
									state <= 5'd9;
									IRWrite <= 1'd0;
									PCWrite <= 1'd1;
									PCsrc <= 2'd2;
									if(jal) begin
										RegWrite <= 1'd1;
										RegDst <= 2'd2;
										MemToReg <= 2'd2;
										end
									end
								else if(jr || jalr) begin
									PCWrite <= 1'd1;
									PCsrc <= 2'd3;
									state <= 5'd15;
									if(jalr) begin
										RegWrite <= 1'd1;
										RegDst <= 2'd1;
										MemToReg <= 2'd2;
										end
									end
							end
				   // calculate memaddr
					5'd2: begin
								if(lw) begin
									state <= 5'd3;
									MemRead <= 1'd1;
									IorD <= 1'd1;
									end
								else if(sw) begin
									state <= 5'd5;
									MemWrite <= 1'd1;
									IorD <= 1'd1;
									end
							end
					// read memory
					5'd3: begin
								state <= 5'd4;
								RegWrite <= 1'd1;
								MemToReg <= 2'd1;
						   end
					// write back
					5'd4: begin
								PCWriteCond <= 1'd0;
								PCWrite <= 1'd1;
								MemWrite <= 1'd0;
								MemRead <= 1'd1;
								IRWrite <= 1'd1;
								RegWrite <= 1'd0;
								PCsrc <= 2'd0;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								ALUsrcA <= 2'd0;
								ALUsrcB <= 3'd1;
								ALUop <= 4'd2;
								IorD <= 1'd0;
								ext <= 1'd0;
								state <= 5'd0;
							end
					// write memory
					5'd5: begin
								PCWriteCond <= 1'd0;
								PCWrite <= 1'd1;
								MemWrite <= 1'd0;
								MemRead <= 1'd1;
								IRWrite <= 1'd1;
								RegWrite <= 1'd0;
								PCsrc <= 2'd0;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								ALUsrcA <= 2'd0;
								ALUsrcB <= 3'd1;
								ALUop <= 4'd2;
								IorD <= 1'd0;
								ext <= 1'd0;
								state <= 5'd0;
							end
					// Rtype-ALU execution
					5'd6: begin
								RegWrite <= 1'd1;
								RegDst <= 2'd1;
								MemToReg <= 2'd0;
								state <= 5'd7;
							end
					// Rtype-ALU completion
					5'd7: begin
								PCWriteCond <= 1'd0;
								PCWrite <= 1'd1;
								MemWrite <= 1'd0;
								MemRead <= 1'd1;
								IRWrite <= 1'd1;
								RegWrite <= 1'd0;
								PCsrc <= 2'd0;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								ALUsrcA <= 2'd0;
								ALUsrcB <= 3'd1;
								ALUop <= 4'd2;
								IorD <= 1'd0;
								ext <= 1'd0;
								state <= 5'd0;
							end
					// branch completion
					5'd8: begin
								PCWriteCond <= 1'd0;
								state <= 5'd31;
							end
					// jump execution
					5'd9:	begin
								PCWrite <= 1'd0;
								RegWrite <= 1'd0;
								state <= 5'd14;
							end
					// Itype_ALU execution
					5'd10: begin
								RegWrite <= 1'd1;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								state <= 5'd11;
							 end
					// Itype_ALU completion
					5'd11: begin
								PCWriteCond <= 1'd0;
								PCWrite <= 1'd1;
								MemWrite <= 1'd0;
								MemRead <= 1'd1;
								IRWrite <= 1'd1;
								RegWrite <= 1'd0;
								PCsrc <= 2'd0;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								ALUsrcA <= 2'd0;
								ALUsrcB <= 3'd1;
								ALUop <= 4'd2;
								IorD <= 1'd0;
								state <= 5'd0;
							 end
					// shift execution
					5'd12: begin
								RegWrite <= 1'd1;
								RegDst <= 2'd1;
								MemToReg <= 2'd0;
								state <= 5'd7;
							 end
					// lui completion
					5'd13: begin
								RegWrite <= 1'd1;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								state <= 5'd11;								
							 end
					// link completion
					5'd14: begin
								PCWriteCond <= 1'd0;
								PCWrite <= 1'd1;
								MemWrite <= 1'd0;
								MemRead <= 1'd1;
								IRWrite <= 1'd1;
								RegWrite <= 1'd0;
								PCsrc <= 2'd0;
								RegDst <= 2'd0;
								MemToReg <= 2'd0;
								ALUsrcA <= 2'd0;
								ALUsrcB <= 3'd1;
								ALUop <= 4'd2;
								IorD <= 1'd0;
								ext <= 1'd0;
								state <= 5'd0;
							 end
					// jump register execution
					5'd15: begin
								state <= 5'd14;
								PCWrite <= 1'd0;
								RegWrite <= 1'd0;
							 end
					default : ;
				endcase
		  end
	 end

endmodule
