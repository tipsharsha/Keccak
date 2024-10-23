`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.08.2024 10:53:28
// Design Name: 
// Module Name: PISO_reg
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

`define DATA_SIZE 64

module PISO_reg(
    input [1343:0] data_in,
    input rst,
    input load_en,
    input shift_en,
    input clk,
    output out_ready,
    
    output [`DATA_SIZE-1:0] data_out
    );
    
    reg [1343:0] data;
    reg out_ready;
    
    
    always @ (posedge clk, posedge rst) begin
        if (rst) data <= 0;
        else begin
            if(load_en)
                data <= data_in;
            else if(shift_en)
                data <= data<<`DATA_SIZE;
        end
    end
    always @ (posedge clk, posedge rst) begin
        if(rst) out_ready <= 0;
        else if(load_en) out_ready <= 1;
        else if(~shift_en) out_ready <= 0;
    end
    assign data_out = data[1343-:`DATA_SIZE];
    
endmodule
