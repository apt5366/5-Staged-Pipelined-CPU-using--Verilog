`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2020 03:42:05 AM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module testbench();
    reg clk;
    wire [7:0] pc;
    wire [7:0] next_pc;
    wire [31:0] im_out;
    wire [31:0] instr;
    wire wreg;
    wire m2reg;
    wire wmem;
    wire [3:0] aluc;
    wire aluimm;
    wire [1:0] fwd_a;
    wire [1:0] fwd_b;
    wire regrt;
    wire [31:0] mfwa_out; 
    wire [31:0] mfwb_out; 
    wire [4:0] m1_out; 
    wire [31:0] qa;
    wire [31:0] qb;
    wire [31:0] se_out;
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire [3:0] ealuc;
    wire ealuimm;
    wire [4:0] em1_out;
    wire [31:0]eqa;
    wire [31:0]eqb;
    wire [31:0]ese_out;
    wire [31:0] m2_out;
    wire [31:0] alu_out;
    wire mwreg;
    wire mm2reg;
    wire mwmem;
    wire [4:0] mm1_out;
    wire [31:0] malu_out;
    wire [31:0] mqb;
    wire [31:0] data_mem_out;
    wire wwreg;
    wire wm2reg;
    wire [4:0] wm1_out;
    wire [31:0] walu_out;
    wire [31:0] w_data_mem_out; 
    wire [31:0] m3_out;
    
    
//for IF stage
PC pc_tb(clk, next_pc, pc);
adder adder_tb( pc, next_pc);
IM im_tb(pc, im_out);
IF_ID ifid_tb(clk, im_out, instr);

//for ID stage
control_unit cu_tb( instr[31:26],instr[5:0], instr[25:21],instr[20:16], mm1_out, mm2reg, mwreg, em1_out , em2reg, ewreg  , wreg, m2reg, wmem, aluc, aluimm, fwd_b,fwd_a,regrt);

mux_1 mux1_tb(regrt,instr[15:11], instr[20:16], m1_out);
reg_file regfile_tb(~clk,wwreg, instr[25:21], instr[20:16],wm1_out,m3_out, qa, qb);
mux_forw_a muxfa_tb(fwd_a,qa, alu_out, malu_out, data_mem_out, mfwa_out );
mux_forw_b muxfb_tb(fwd_b,qb, alu_out, malu_out, data_mem_out, mfwb_out );

sign_extender se_tb(instr[15:0], se_out); //takes in the 16 bit constant and makes it 32 bits
ID_EXE idexe_tb(clk, wreg, m2reg, wmem, aluc, aluimm, m1_out, mfwa_out, mfwb_out , se_out , ewreg ,em2reg, ewmem, ealuc, ealuimm,em1_out, eqa, eqb, ese_out);

// for EXE stage
mux_2 mux2_tb(ealuimm,eqb,ese_out, m2_out);
ALU alu_tb(ealuc, /*eqa*/ eqa, m2_out, alu_out);
EXE_MEM exemem_tb(clk, ewreg, em2reg, ewmem, em1_out,alu_out, eqb , mwreg, mm2reg, mwmem, mm1_out,malu_out, mqb);

// for MEM stage
data_mem dm_tb(mwmem, malu_out, mqb, data_mem_out);
MEM_WB memwb_tb(clk,mwreg, mm2reg, mm1_out, malu_out, data_mem_out, wwreg, wm2reg, wm1_out, walu_out, w_data_mem_out );
mux_3 mux3_tb(wm2reg,walu_out,w_data_mem_out,m3_out);

always #5 clk = ~clk;

initial begin
    clk = 0;
   // pc= 8'b100;
    // next_pc= 8'b100;
    
//    ewreg <= 0 ;
//    em2reg <= 0;
//    ewmem <= 0;
//    ealuc <= 4'b0;
//    ealuimm<=0;
//    em1_out<= 5'b0;
//    eqa <=32'b0;
//    eqb<= 32'b0;
//    ese_out<= 32'b0;
    
    
#100;
$stop;
end

endmodule

