`include "padder.v"
`include "SIPO_reg.v"
`include "f_permutation.v"
`define DATA_SIZE 64

module keccak(
    input clk,
    input rst,
    input [63:0] in, // Represents the seed
    input [1:0] mode,
    input is_last, // Indicated the last input seed
    input start_calc, // signifies vaild instruction
    input gimme, // handshaking from parse and CBD
    output ack,
    input in_valid,//total goes to padding
    output [63:0] out,
    output out_ready,
    output out_buf_empty // Output FIFO is empty
    );

    wire[63:0] pad_out;
    wire pad_out_ready;
    reg mode_reg;
    wire f_in_ready;
    wire f_out_ready;
    wire[1343:0]f_in;
    wire cntr_zero;
    wire f_ack;
    wire squeeze;
    wire [1599:0] f_out;

    reg takein;

    padder pad(
    .in_valid(in_valid),
    .takein(takein),
    .clk(clk),
    .rst(rst),
    .in(in),
    .out(pad_out),
    .out_ready(pad_out_ready),
    .is_last(is_last),
    .mode(mode_reg),
    .ack(ack),
    .start_calc(start_calc),
    .cntr_zero(cntr_zero));
    
    SIPO sipo (
     .data_in(pad_out),
     .hash_init(rst | start_calc),
     .load_en(pad_out_ready & ~f_ack),
     .clk(clk),
     .cntr_zero(cntr_zero),
     .is_loaded(f_in_ready),
     .data_out(f_in)
    );

    f_permutation f
    (.mode(mode_reg),
    .clk(clk),
    .reset(rst),
    .in(f_in),
    .in_ready(f_in_ready),
    .ack(f_ack),
    .out(f_out),
    .out_ready(f_out_ready),
    .squeeze(squeeze));

    always @(posedge clk, posedge rst) begin
        if(rst) mode_reg<=0;
        else if(start_calc) mode_reg<=mode;
    end

    always @ (posedge clk, posedge rst) begin
        if (rst) takein <= 0;
        else if (start_calc) takein <= 1;
        else if (is_last) takein <= 0;
    end

endmodule