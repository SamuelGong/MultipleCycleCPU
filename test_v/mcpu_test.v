`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:18:37 05/11/2017
// Design Name:   MCPU_v1
// Module Name:   E:/My universe/university/Course/Computer Organization/Lab/Source/Exp06/MultipleCycle/mcpu_test.v
// Project Name:  MultipleCycle
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MCPU_v1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mcpu_test;

	// Inputs
	reg clk;
	reg reset;
	reg [31:0] Data_in;
	reg [4:0] test_reg_index;
	reg INT;
	reg MIO_ready;

	// Outputs
	wire mem_w;
	wire [31:0] Addr_out;
	wire [31:0] Data_out;
	wire [4:0] state;
	wire [31:0] PC_out;
	wire [31:0] inst_out;
	wire [31:0] test_reg_result;
	wire CPU_MIO;

	// Instantiate the Unit Under Test (UUT)
	MCPU_v1 uut (
		.clk(clk), 
		.reset(reset), 
		.mem_w(mem_w), 
		.Addr_out(Addr_out), 
		.Data_out(Data_out), 
		.Data_in(Data_in), 
		.state(state), 
		.PC_out(PC_out), 
		.inst_out(inst_out), 
		.test_reg_index(test_reg_index), 
		.test_reg_result(test_reg_result), 
		.INT(INT), 
		.MIO_ready(MIO_ready), 
		.CPU_MIO(CPU_MIO)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		Data_in = 0;
		test_reg_index = 0;
		INT = 0;
		MIO_ready = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		
		Data_in = 32'h20210001; // begin : addi $1, $1, 1
		test_reg_index = 1; // $1 ought to be 1
		#160;
		
		Data_in = 32'h00211020; //add $2, $1, $1
		#20;
		test_reg_index = 2; // $2 ought to be 2
		#140;
		
		Data_in = 32'h34630003; // ori $3, $3, 3
		#20;
		test_reg_index = 3; // $3 ought to be 3
		#140;
		
		Data_in = 32'h00622022; // $4 sub $4, $3, $2
		#20;
		test_reg_index = 4; // $4 ought to be 1
		#140;
		
		Data_in = 32'h00432827; // nor $5, $2, $3
		#20;
		test_reg_index = 5; // $5 ought to be 0xFFFFFFFC
		#140;
		
		Data_in = 32'h00433026; // xor $6, $2, $3
		#20;
		test_reg_index = 6; // $6 ought to be 0x00000001
		#140;
		
		Data_in = 32'h0043382A; // slt $7, $2, $3
		#20;
		test_reg_index = 7; // $7 ought to be 1
		#140;
		
		Data_in = 32'h28E8FFFF; // slti $8, $7. -1
		#20;
		test_reg_index = 8; // $8 ought to be 0
		#140;
		
		Data_in = 32'h00014FC0; // sll $9, $1, 31
		#20;
		test_reg_index = 9; // $9 ought to be 0x80000000;
		#140;
		
		Data_in = 32'h000957C2; // srl $10, $9, 31;
		#20;
		test_reg_index = 10; // $10 ought to be 0x00000001
		#140;
		
		Data_in = 32'h01405825; // or $11, $10, $0
		#20;
		test_reg_index = 11; // $11 ought to be 1
		#140;
		
		Data_in = 32'h316CFFFF; // andi $12, $11, 0xFFFF
		#20;
		test_reg_index = 12; // $12 ought to be 1
		#140;
		
		Data_in = 32'h3C0DFFFF; // lui $13, 0xFFFF
		#20
		test_reg_index = 13; // $13 ought to be 0xFFFF0000
		#140;
		
		Data_in = 32'h39AE0000; // xori $14, $13, 0x0000
		#20;
		test_reg_index = 14; // $14 ought to be 0xFFFF0000
		#140; 
		
		Data_in = 32'h11C0FFF1; // beq $14, $0, begin
		#160;
		
		Data_in = 32'h1400FFF0; // bne $0, $0, begin
		#160;
		
		/*
		Data_in = 32'h1000FFF1; // beq $0, $0, begin
		#160;
		*/
		
		/*
		Data_in = 32'h15C0FFF0; // bne $14, $0, begin
		#160;
		*/
		Data_in = 32'h08000011; // j L1
		#160;
		
		Data_in = 32'hAC0E0008; // L1: sw $14 8($0)
		#160;
		
		Data_in = 32'h8C0F0008; // lw $15 8($0)
		#50;
		test_reg_index = 15; // $15 ought to be 0x12345678
		Data_in = 32'h12345678;
		#150;
		
		Data_in = 32'h0C000014; // jal L2
		#20;
		test_reg_index = 31; // $31 ought to be 0
		#140;
		
		Data_in = 32'h01E08009; // L2: jalr $15, $16
		#20;
		test_reg_index = 16; // $16 ought to be 0x00000054 , PC ought to be 0x12345678
		#140;
		
        
	end
	
	always @ * begin
		#20;
		clk <= ~clk;
	end
      
endmodule

/*

	initial begin
		// Initialize Inputs
		inst_in = 0;
		Data_in = 0;
		clk = 0;
		reset = 1;
		test_reg_index = 0;

		// Wait 100 ns for global reset to finish
		#30;
		reset = 0;
		inst_in = 32'h20210001; // begin : addi $1, $1, 1
				#10;
				test_reg_index = 1; // $1 ought to be 1
				#20;
		inst_in = 32'h00211020; //add $2, $1, $1
				#20;
				test_reg_index = 2; // $2 ought to be 2
				#20;
		inst_in = 32'h34630003; // ori $3, $3, 3
				#20;
				test_reg_index = 2; // $3 ought to be 3
				#20;
		inst_in = 32'h00622022; // $4 sub $4, $3, $2
				#20;
				test_reg_index = 4; // $4 ought to be 1
				#20;
		inst_in = 32'h00432827; // nor $5, $2, $3
				#20;
				test_reg_index = 5; // $5 ought to be 0xFFFFFFFC
				#20;
		inst_in = 32'h00433026; // xor $6, $2, $3
				#20;
				test_reg_index = 6; // $6 ought to be 0x00000001
				#20;
		inst_in = 32'h0043382A; // slt $7, $2, $3
				#20;
				test_reg_index = 7; // $7 ought to be 1
				#20;
		inst_in = 32'h28E8FFFF; // slti $8, $7. -1
				#20;
				test_reg_index = 8; // $8 ought to be 0
				#20;
		inst_in = 32'h00014FC0; // sll $9, $1, 31
				#20;
				test_reg_index = 9; // $9 ought to be 0x80000000;
				#20;
		inst_in = 32'h000957C2; // srl $10, $9, 31;
				#20;
				test_reg_index = 10; // $10 ought to be 0x00000001
				#20;
		inst_in = 32'h01405825; // or $11, $10, $0
				#20;
				test_reg_index = 11; // $11 ought to be 1
				#20;
		inst_in = 32'h316CFFFF; // andi $12, $11, 0xFFFF
				#20;
				test_reg_index = 12; // $12 ought to be 1
				#20;
		inst_in = 32'h3C0DFFFF; // lui $13, 0xFFFF
				#20;
				test_reg_index = 13; // $13 ought to be 0xFFFF0000
				#20;
		inst_in = 32'h39AE0000; // xori $14, $13, 0x0000
				#20;
				test_reg_index = 14; // $14 ought to be 0xFFFF0000
				#20; 
		inst_in = 32'h11C0FFF1; // beq $14, $0, begin
				#40;
		inst_in = 32'h1400FFEF; // bne $0, $0, begin
				#40;
		inst_in = 32'h08000011; // j L1
				#40;
		inst_in = 32'h00000000;
				#40;
		inst_in = 32'hAC0E0008; // L1: sw $14 8($0)
				#40;
		inst_in = 32'h8C0F0008; // lw $15 8($0)
		Data_in = 32'h12345678;
				#20;
				test_reg_index = 15; // $15 ought to be 0x12345678
				#20;
		inst_in = 32'h0C000014; // jal L2
				#20;
				test_reg_index = 31; // $31 ought to be 0
				#20;
		inst_in = 32'h01E08009; // L2: jalr $15, $16
				#20;
				test_reg_index = 16; // $16 ought to be 0x12345678
				#20;
	end
    
	always @ * begin
		#20;
		clk <= ~clk;
	end
	
endmodule

*/

