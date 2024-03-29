`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2020 03:39:41 AM
// Design Name: 
// Module Name: PC
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


module PC(
    input wire clk,
    input wire [7:0] pc_in,
    output reg [7:0] pc_out
    );
    
//    initial begin
//        pc_out <= 100;
//    end
    
//     assign pc_out <= 8'b100;
    initial begin
          pc_out <= 8'd100;
    end
     
    always @(posedge clk) begin
        pc_out <= pc_in;
    end
    
endmodule

module adder(
    input wire [7:0] pc,
    output reg [7:0] next_pc
    );
    
    initial begin
          next_pc <= 8'd100;
    end
    always @(pc) begin
        next_pc <= pc+ 8'd4;
    end
endmodule

module IM(
    input wire [7:0] pc,
    output  reg [31:0] instr
    );
    
    reg [31:0] im [0:511];

//        im[100] = 32'b000000  00001 00010 00011 00000 100000
//        im[104] = 32'b000000  01001 00011 00100 00000 100010

//        im[108] = 32'b000000  00011 01001 00101 00000 100101
//        im[112] = 32'b000000  00011 01001 00110 00000 100110
//        im[116] = 32'b000000  00011 01001 00111 00000 100100

//        im[100] = 32'b00000000001000100001100000100000
//        im[104] = 32'b00000001001000110010000000100010

//        im[108] = 32'b00000000011010010010100000100101
//        im[112] = 32'b00000000011010010011000000100110
//        im[116] = 32'b00000000011010010011100000100100




    
    initial begin
        im[8'd100] = 32'h221820;    // Add
        im[8'd104] = 32'h1232022;   // Sub
        im[8'd108] = 32'h692825;    // Or
        im[8'd112] = 32'h693026;   // XOR
        im[8'd116] = 32'h693824;   // AND
        
        instr <= 32'h0;
    end
    
    always@(pc) begin
        instr <= im[pc];
    end
endmodule


module IF_ID(
    input wire clk,
    input wire [31:0] val_in,
    output reg [31:0] val_out
    );   
    always @(posedge clk) begin
        val_out <= val_in;
    end    
endmodule


module control_unit(
    input wire [5:0] op,
    input wire [5:0] func,
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] mm1_out,
    input wire mm2reg,
    input wire mwreg,
    input wire [4:0] em1_out,
    input wire em2reg,
    input wire ewreg,
    output reg wreg,
    output reg m2reg,
    output reg wmem,
    output reg [3:0] aluc,
    output reg aluimm, 
    output reg [1:0] fwd_b,
    output reg [1:0] fwd_a,
    output reg regrt
    
    );
    
    initial begin
        fwd_a <= 2'b00;
        fwd_b <= 2'b00;
        
    end
    
    always@(op, func) begin
        if(op==6'b100011) begin // we will know that its lw
            wreg <= 1;
            m2reg <= 1;
            wmem <= 0;
            aluc <= 4'b0010;
            aluimm <= 1;
            regrt <= 1;
        end
        else if(op==6'b000000)begin // this will be an r-type fiunc 
            
            // deciding which r-type function it is
            //
            if(func==6'b100000)begin // add
                wreg <= 1;
                m2reg <= 0;
                wmem <= 0;
                aluc <= 4'b0010;
                aluimm <= 0;
                regrt <= 0;
             end 
             else if(func==6'b100010)begin // sub
                wreg <= 1;
                m2reg <= 0;
                wmem <= 0;
                aluc <= 4'b0110;
                aluimm <= 0;
                regrt <= 0;
             end
             else if(func==6'b100100)begin // aNd
                wreg <= 1;
                m2reg <= 0;
                wmem <= 0;
                aluc <= 4'b0000;
                aluimm <= 0;
                regrt <= 0;
             end
             else if(func==6'b100101)begin // or
                wreg <= 1;
                m2reg <= 0;
                wmem <= 0;
                aluc <= 4'b0001;
                aluimm <= 0;
                regrt <= 0;
             end
             else if(func==6'b100110)begin // Xor
                wreg <= 1;
                m2reg <= 0;
                wmem <= 0;
                aluc <= 4'b1001; // if chagnge this, the change ALU as welll  // MAKE SURE ABOUT THIS BEFORE SUBMitting
                aluimm <= 0;
                regrt <= 0;
             end
        end
        
        
        // input (a) for ALU
        if(rs == em1_out)begin
            fwd_a <=2'b01; // send alu_out to output of fwd_a
        end
        else if(rs == mm1_out) begin
             fwd_a <=2'b10; // send Malu_out to output of fwd_a        
        end
        else 
            fwd_a <=2'b00;
            
        //input (b) for ALU
        if(rt == em1_out)begin
            fwd_b <= 2'b01; // send alu_out to output of fwd_b
        end
        else if(rt == mm1_out)begin
            fwd_b <= 2'b10; // send Malu_out to output of fwd_b
        end
        else
            fwd_b <= 2'b00;
        
//        if(rt == em1_out )begin
        
        
//        end
    end
   
endmodule

module mux_1(
    input wire regrt,
    input wire [4:0] rd,
    input wire [4:0] rt,
    output reg [4:0] m1_out
    );
    
    always @(*) begin
        if(regrt== 1'b1) begin
            m1_out <= rt;
        end
        else
            m1_out <= rd;
    end    
endmodule

module reg_file(
    input wire clk,
    input wire wwreg,
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire[4:0] wm1_out,
    input wire [31:0] m3_out,
    output reg [31:0] qa,
    output reg [31:0] qb
    );
    reg [31:0] reg_f [0:31];
    integer i;  
    
    initial begin
//        for(i=0;i<=31;i=i+1) begin
//             reg_f[i] <= 32'b0;
//        end

        reg_f[0] = 32'h00000000; 
        reg_f[1] = 32'ha00000aa; 
        reg_f[2] = 32'h10000011;  
        reg_f[3] = 32'h20000022;  
        reg_f[4] = 32'h30000033;  
        reg_f[5] = 32'h40000044;  
        reg_f[6] = 32'h50000055;  
        reg_f[7] = 32'h60000066;  
        reg_f[8] = 32'h70000077;  
        reg_f[9] = 32'h80000088;  
        reg_f[10] = 32'h90000099;  
           
     end   
//    always@(rs, rt) begin
    always@(posedge clk) begin
    
//        for(i=0;i<=31;i=i+1) begin
//             reg_f[i] <= 32'b0;
//        end
        
        //READ
        //
        qa <= reg_f[rs];
        qb <= reg_f[rt];
               
    end
    
    always@(negedge clk) begin
        // WRITE
        //
        if(wwreg==1) begin
            reg_f[wm1_out]<= m3_out;
        end
    end
    
endmodule


module mux_forw_a(
    input wire [1:0] fwd_a,
    input wire [31:0] qa, 
    input wire [31:0] alu_out,
    input wire [31:0] malu_out, 
    input wire [31:0] data_mem_out, 
    output reg [31:0] mfwa_out  
    );
    
    always @(*)begin 
        
        if(fwd_a== 2'b00) begin
            mfwa_out<= qa;
        end
        else if(fwd_a== 2'b01) begin
            mfwa_out<= alu_out;
        end
        else if(fwd_a== 2'b10) begin
             mfwa_out<= malu_out;
        end
        else if(fwd_a== 2'b11) begin
             mfwa_out<= data_mem_out;
        end
            
    
    end
    
    
endmodule

module mux_forw_b(
    input wire [1:0] fwd_b,
    input wire [31:0] qb, 
    input wire [31:0] alu_out,
    input wire [31:0] malu_out, 
    input wire [31:0] data_mem_out, 
    output reg [31:0] mfwb_out  
    );
    
    always @(*)begin 
        
        if(fwd_b== 2'b00) begin
            mfwb_out<= qb;
        end
        else if(fwd_b== 2'b01) begin
            mfwb_out<= alu_out;
        end
        else if(fwd_b== 2'b10) begin
             mfwb_out<= malu_out;
        end
        else if(fwd_b== 2'b11) begin
             mfwb_out<= data_mem_out;
        end
            
    
    end
endmodule

module sign_extender(
    input wire [15:0] instr_const,
    output reg [31:0] se_out
    );
    
    always @(instr_const) begin
        se_out <= {{16{instr_const[15]}} , instr_const};
    end
    
endmodule

module ID_EXE(
    input wire clk,
    input wire wreg,
    input wire m2reg,
    input wire wmem,
    input wire [3:0]aluc,
    input wire aluimm,
    input wire [4:0] m1_out,
    input wire [31:0] qa,
    input wire [31:0]qb,    
    input wire [31:0]se_out,
    
    output reg ewreg,
    output reg em2reg,
    output reg ewmem,
    output reg [3:0] ealuc,
    output reg ealuimm,
    output reg [4:0] em1_out,
    output reg [31:0]eqa,
    output reg [31:0]eqb,
    output reg [31:0]ese_out
    
    );
    
    always@(posedge clk)  begin    
        ewreg <= wreg;
        em2reg <= m2reg;
        ewmem <= wmem;
        ealuc <= aluc;
        ealuimm <= aluimm;
        em1_out <= m1_out;
        eqa <= qa;
        eqb <= qb;
        ese_out <= se_out;
    
    end 

endmodule

module mux_2(
    input wire ealuimm,
    input wire [31:0] eqb,
    input wire [31:0] ese_out,
    output reg [31:0] m2_out
    );
    
    always@(*)begin
        if(ealuimm==0)begin
            m2_out<= eqb;
        end
        else
            m2_out <= ese_out;
        
    end   
endmodule



module ALU(
    input wire [3 :0] ealuc,
    input wire [31:0] eqa,
    input wire [31:0] m2_out,
    output reg [31:0] alu_out 
    );
   
    always@(*)begin
        if(ealuc==4'b0000) //AND
            alu_out<= eqa & m2_out;
        else if(ealuc==4'b0001) //OR
            alu_out<= eqa | m2_out;
        else if(ealuc==4'b0010) // add
            alu_out<= eqa + m2_out;
        else if(ealuc==4'b0110) // sub
            alu_out<= eqa - m2_out;
        else if(ealuc==4'b1001) // xor
            alu_out<= eqa ^ m2_out;
        
 
    end
    
endmodule 

module EXE_MEM(
    input wire clk,
    input wire ewreg,
    input wire em2reg,
    input wire ewmem,
    input wire [4:0] em1_out,
    input wire [31:0] alu_out,
    input wire [31:0] eqb,    
    output reg mwreg,    
    output reg mm2reg,    
    output reg mwmem,   
    output reg [4:0] mm1_out,    
    output reg [31:0] malu_out,    
    output reg [31:0] mqb
    );
    
    always@(posedge clk)begin
        mwreg <= ewreg;
        mm2reg <= em2reg;
        mwmem <= ewmem ;
        mm1_out <= em1_out;
        malu_out <= alu_out ;  
        mqb <= eqb;   
    end
 endmodule
 
 
 module data_mem(
    input wire mwmem,
    input wire [31:0]malu_out,
    input wire [31:0]mqb,
    output reg [31:0]do
    );
    
    reg [31:0] data_m [0:511];
       
    initial begin
        data_m[0] = 32'ha00000aa; 
        data_m[4] = 32'h10000011;  
        data_m[8] = 32'h20000022;  
        data_m[12] = 32'h30000033;  
        data_m[16] = 32'h40000044;  
        data_m[20] = 32'h50000055;  
        data_m[24] = 32'h60000066;  
        data_m[28] = 32'h70000077;  
        data_m[32] = 32'h80000088;  
        data_m[36] = 32'h90000099;  
//        data_m[40] = 32'h8c030004;        
    end// use
    
    always@(*) begin    
        if(mwmem==0)begin // means we are reading from the data memory
            do <= data_m[malu_out];            
        end
        else if(mwmem==1) begin
//            data_m[]<=;
//            do <= data_m[mqb];
            data_m[malu_out]=mqb;
        end
    end
    
 endmodule 
 
 module MEM_WB(
    input wire clk,
    input wire mwreg,
    input wire mm2reg,
    input wire[4:0] mm1_out,
    input wire [31:0] malu_out,
    input wire [31:0] data_mem_out,
    output reg wwreg,
    output reg wm2reg,
    output reg [4:0] wm1_out,
    output reg [31:0] walu_out,
    output reg [31:0] w_data_mem_out
    );
    
    always@(posedge clk) begin
        wwreg <= mwreg;
        wm2reg <=mm2reg;
        wm1_out <= mm1_out ;
        walu_out <= malu_out;
        w_data_mem_out <= data_mem_out; 
    end
    
 endmodule
 
 module mux_3(
    wire wm2reg,
    wire [31:0] walu_out,
    wire [31:0] w_data_mem_out, 
    output reg [31:0] m3_out
   );
   
   always@(wm2reg or walu_out or w_data_mem_out) begin
        if(wm2reg==0)begin
            m3_out<= walu_out;
        end
        else begin
            m3_out <= w_data_mem_out;
        end
   end
   
endmodule

