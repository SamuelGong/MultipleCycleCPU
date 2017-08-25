`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:22:41 05/10/2017 
// Design Name: 
// Module Name:    MCPU_v1 
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
module MCPU_v1(input clk,//muliti_CPU
					input	reset,
					output mem_w,
					output[31:0] Addr_out,
					output[31:0] Data_out,
					input [31:0] Data_in,
					// test
					output[4:0] state,		
					output[31:0] PC_out,		
					output[31:0] inst_out,	
					input [4:0] test_reg_index,		
					output [31:0] test_reg_result,	
					// not used
					input INT,
					input MIO_ready,
					output CPU_MIO
);
		
		wire [31:0] PC_o;
		reg [31:0] PC;
		wire [31:0] PCsrc_o;
		wire [31:0] IorD_o;
		
		wire [31:0] MDR_o;
		reg [31:0] MDR;

		wire [31:0] IR_o;
		reg [31:0] IR;
		
		wire [31:0] Rs_i, Rs_o, Rt_i, Rt_o;
		reg [31:0] Rs, Rt;
		
		wire [31:0] ALUout_i, ALUout_o;
		reg [31:0] ALUout;
		
		wire [31:0] extshift;
		wire [31:0] jump_addr;
		wire branch_taken;
		wire PCchange;
		
		wire 	PCWriteCond,	PCWrite,	IorD,
				MemWrite, 		IRWrite,	ext,
				RegWrite,		beq,		bne;
				
		wire [1:0] MemToReg,	RegDst,	ALUsrcA, PCsrc;
		wire [2:0] ALUsrcB;
		wire [3:0] ALUop;
		wire [4:0] State_o;
		
		wire [31:0] PCsrcMux_o, IorDMux_o, RegDstMux_o, 
						MToRMux_o, ALUsrcAMux_o, ALUsrcBMux_o, 
						extMux_o, signExt_o, zeroExt_o;

		// PC
		
		always @ (posedge clk or posedge reset) begin
			if(reset)
				PC <= 0;
			else if(PCchange)
				PC <= PCsrcMux_o;
		end
		assign PC_o = PC;
		
		MUX4T1_32 PCsrcMux( 	.s(PCsrc), 	.I0(ALUout_i), 	.I1(ALUout_o), 
									.I2(jump_addr), 	.I3(Rs_o), 	.o(PCsrcMux_o));
									
		MUX2T1_32 IorDMux(	.s(IorD), 	.I0(PC_o), 		.I1(ALUout_o),
									.o(IorDMux_o));
		assign Addr_out = IorDMux_o;
		
		assign Data_out = Rt_o;
		
		// MDR
		
		always @ (posedge clk or posedge reset) begin
			if(reset)
				MDR <= 0;
			else
				MDR <= Data_in;
		end
		assign MDR_o = MDR;
		
		// IR
		
		always @ (posedge clk or posedge reset) begin
			if(reset)
				IR <= 0;
			else if(IRWrite)
				IR <= Data_in;
		end
		assign IR_o = IR;
		
		// register files
		MUX4T1_5 RegDstMux(	.s(RegDst),	.I0(IR_o[20:16]),	.I1(IR_o[15:11]),
									.I2(32'd31), 	.I3(),	.o(RegDstMux_o));
									
		MUX4T1_32 MToRMux(	.s(MemToReg),	.I0(ALUout_o),	.I1(MDR_o),	
										.I2(PC_o), 		.I3(),			.o(MToRMux_o));
		
		
		Regs registerFiles(	.clk(clk),	.rst(reset),	.we(RegWrite),
									.reg_Rs_addr_A(IR_o[25:21]),
									.reg_Rt_addr_B(IR_o[20:16]),
									.reg_Wt_addr(RegDstMux_o),	.wdata(MToRMux_o),
									.rdata_A(Rs_i), .rdata_B(Rt_i),
									.test_reg_index(test_reg_index),
									.test_reg_result(test_reg_result));
		
		
		always @ (posedge clk or posedge reset) begin
			if(reset) begin
				Rs <= 0;
				Rt <= 0;
			end
			else begin
				Rs <= Rs_i;
				Rt <= Rt_i;
			end
		end
		assign Rs_o = Rs;
		assign Rt_o = Rt;
		
		// ALU
		MUX4T1_32 ALUsrcAMux(	.s(ALUsrcA),	.I0(PC_o), 			.I1(Rs_o),
										.I2(Rt_o), 		.I3(extMux_o),		.o(ALUsrcAMux_o));
										
		MUX8T1_32 ALUsrcBMux(	.s(ALUsrcB),	.I0(Rt_o),	.I1(32'h00000004),
										.I2(extMux_o),	.I3(extshift),
										.I4(IR_o),		.I5(32'h00000400),	
										.I6(),	.I7(),	.o(ALUsrcBMux_o));
		
		ALU_v1 ALU(	.ALU_operation(ALUop), 	.A(ALUsrcAMux_o),	.B(ALUsrcBMux_o),
						.overflow(),	.zero(zero),	.res(ALUout_i));
		
		
		always @ (posedge clk or posedge reset) begin
			if(reset)
				ALUout <= 0;
			else
				ALUout <= ALUout_i;
		end
		assign ALUout_o = ALUout;
		
		// shift and extension
		signExt_16T32 signExt(	.i(IR_o[15:0]),	.o(signExt_o));
		zeroExt_16T32 zeroExt(	.i(IR_o[15:0]), .o(zeroExt_o));
		
		MUX2T1_32 extMux(	.s(ext),	.I0(zeroExt_o),	.I1(signExt_o),
							.o(extMux_o));
		
		
		assign extshift = extMux_o << 2;
		
		assign jump_addr = {PC_o[31:28], IR_o[25:0], 2'b0};
		
		// other logical circuits
		
		assign branch_taken = beq & zero | bne & ~zero ;
		
		assign PCchange = PCWrite | PCWriteCond & branch_taken;
		
		// controller
		
		M_controller controller(	.clk(clk),		.rst(reset),
											.inst(IR_o),	.PCWriteCond(PCWriteCond),	
											.PCWrite(PCWrite),	.IorD(IorD),	.MemWrite(MemWrite),
											.IRWrite(IRWrite),	.ext(ext),		.RegWrite(RegWrite),
											.beq_o(beq),	.bne_o(bne),	.MemRead(),
											.MemToReg(MemToReg),	.RegDst(RegDst),	.ALUsrcA(ALUsrcA),
											.ALUsrcB(ALUsrcB),	.PCsrc(PCsrc),		.ALUop(ALUop),
											.State_o(state));
		
		assign mem_w = MemWrite;
		
		assign inst_out = IR_o;
		assign PC_out = PC_o;
endmodule
 