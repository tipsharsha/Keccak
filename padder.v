
module padder(
    input clk,
    input rst,
    input [63:0]in,
    input in_valid,
    input start_calc,
    input takein,
    output [63:0]out,
    output reg out_ready,
    input is_last,
    input mode,
    output reg ack,
    output cntr_zero
    );
    reg [63:0] pad_out;
    reg [4:0] cntr;
    reg latch_last;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            cntr <= 0;
            pad_out<=0;
        end
        else if(in_valid & (cntr!=0))
            cntr <= cntr - 1;
    end
    always @(posedge clk) begin
        if (start_calc | (takein & (cntr == 0))) begin
            case(mode)
                    0: cntr <= 8;
                    1: cntr <= 16;
                    2: cntr <= 20;
                    3: cntr <= 16;
            endcase
        end
    end
    always @(posedge clk) begin
        out_ready <= 0;
        ack<=0;
        if(in_valid & ~is_last &cntr!=0) begin
            pad_out <= in;
            out_ready<=1;
            ack<=1;
        end
        else if(is_last & cntr !=0)
        begin
            pad_out <= {1'b1, {63{1'b0}}};
            latch_last<=1;
            out_ready<=1;
        end
        else if(latch_last & cntr!=0) begin
            pad_out<=0;
            out_ready<=1;
        end
        else if(latch_last & cntr==0)
        begin
            pad_out<=1;
            latch_last<=0;
            out_ready<=1;
        end

    end
    assign cntr_zero = (cntr==0);

endmodule