// // `include "Sync_FIFO.v"
// // `include "SIPO_reg.v"
// // `include "f_permutation.v"
// // `include "PISO_reg.v"

// `define DATA_SIZE 64
// module keccak(
//     input clk,
//     input reset,
//     input [63:0] in, // Represents the seed
//     // input [1567:0] pk, // Represents the public key
//     // input in_ready,
//     input rd_en,
//     // input [1:0] i,
//     // input [1:0] j,
//     input [1:0] mode,
//     // input [1:0] num_squeeze,
//     // input end_seed, 
//     input start_calc, // signifies vaild instruction
//     input gimme, // handshaking from parse and CBD
//     // output ack,
//     output [63:0] out,
//     // output out_ready,
//     // output buf_full, // Input FIFO is full
//     output out_buf_empty // Output FIFO is empty
//     );

//     wire [1343:0]reg_out;
//     // wire out_ready;
//     wire squeeze;
//     wire shift_en;
//     wire [63:0] buf_out;
//     wire buf_empty;
//     wire [1599:0] fout;
//     wire f_out_ready;
//     wire p_out;

//     wire sipo_load_en = ((mode_reg == 1) & ((~buf_empty) & (cntr != 0))) 
//                         | ((mode_reg == 2) & (cntr != 0))
//                         | ((mode_reg == 3) & (cntr != 0));

//     // reg [1:0] ns;
//     // reg [4:0] num_out;
//     reg [4:0] cntr;   
//     // Registers to store G
//     // reg [1:0] i_reg;
//     // reg [1:0] j_reg;
//     reg [319:0] rho; // 259:258 - i, 257:256 - j, 255:0 - rho
//     reg [319:0] sigma; // 257:256 - i, 255:0 - sigma 
//     reg [1:0] mode_reg; // To latch the mode 

//     reg [63:0] SIPO_in; 
//     // reg [8:0] rho_ptr;
//     // reg [8:0] sigma_ptr;

//     // assign squeeze = ns==0?0:1;
//     // assign out_ready = f_out_ready;
//     //Says that the buffer is full when the number of outputs is equal to the number of outputs

//     assign squeeze = gimme & out_buf_empty & (~ absorb) & (~shift_en); 

//     // Sync_FIFO fifo (.clk(clk), .rst(reset), .buf_in(in), .buf_out(buf_out), .wr_en(~end_seed), .rd_en(sipo_load_en & (mode == 1)), .buf_empty(buf_empty), .buf_full(buf_full)); //, .fifo_counter(num_out));
//     SIPO_reg SIPO (.data_in(SIPO_in), .hash_init(reset | start_calc), .load_en(sipo_load_en), .clk(clk), .data_out(reg_out));
//     f_permutation f_perm (.mode(mode), .clk(clk), .reset(reset), .in(reg_out), .in_ready(), .ack(ack), .out(fout), .out_ready(f_out_ready), .squeeze(squeeze));
//     PISO_reg PISO (.data_in(fout[1599-:1344]), .rst(reset|start_calc), .load_en(f_out_ready), .clk(clk), .data_out(p_out),.shift_en(shift_en),.out_ready(out_ready));
//     Sync_FIFO FIFO_out(.clk(clk), .rst(reset), .buf_in(p_out), .buf_out(out), .wr_en(out_ready), .rd_en(gimme), .buf_empty(out_buf_empty), .buf_full(~shift_en)); //, .fifo_counter(num_out));
    
//     always @ (posedge clk, posedge rst) begin
//         if (rst) begin
//             // rho <= 0;
//             // sigma <= 0;
//             cntr <= 0;
//             mode_reg <= 0;
//         end
//         else if (start_calc) begin
//             // rho[259:258] <= i;
//             // rho[257:256] <= j;
//             // sigma[257:256] <= i;
//             mode_reg <= mode;
//             case (mode)
//                 0: cntr <= 17; 
//                 1: cntr <= 9;
//                 2: cntr <= 21;
//                 3: cntr <= 17;
//             endcase
//         end
//     end

//     // always @ (*) begin
//     //     case (mode_reg)
//     //         0: SIPO_in = 0; // For H
//     //         1: SIPO_in = buf_out;
//     //         2: SIPO_in = rho[rho_ptr-:64];
//     //         3: SIPO_in = sigma[sigma_ptr-:64];
//     //     endcase
//     // end

//     // always @ (posedge clk) begin
//     //     if (start_calc) begin
//     //         rho_ptr <= 319;
//     //         sigma_ptr <= 319;
//     //     end
//     //     else if (sipo_load_en) begin
//     //         case (mode_reg)
//     //             2: rho_ptr <= rho_ptr - 64;
//     //             3: sigma_ptr <= sigma_ptr - 64;
//     //             default: begin
//     //                 rho_ptr <= rho_ptr;
//     //                 sigma_ptr <= sigma_ptr;
//     //             end
//     //         endcase
//     //     end
//     // end

//     // always @ (posedge clk) begin
//     //     //num_squeeze -=1;
//     //     if(end_seed == 1)
//     //         if (ns == 0)
//     //             ns = 0;
//     //         else
//     //             ns = ns - 1; 
//     // end

//     // always @ (posedge clk, posedge reset) begin
//     //     if (reset) ns <= 0;
//     //     else if (start_calc) ns <= num_squeeze;
//     // end

//     // always @ (posedge clk) begin
//     //     if (reset) begin 
//     //         num_out <= 0;
//     //     end
//     //     else if (start_calc) begin
//     //         case(mode)
//     //             0: num_out <= 8;
//     //             1: num_out <= 4;
//     //             2: num_out <= 21;
//     //             3: num_out <= 17;
//     //         endcase
//     //     end
        
//     // end
//     // always @ (posedge clk) begin
//     //     if (reset) begin
//     //         cntr <= 0;
//     //     end
//     //     else if (start_calc) begin
//     //         case(mode)
//     //             0: cntr <= 9;
//     //             1: cntr <= 17;
//     //             2: cntr <= 21;
//     //             3: cntr <= 17;
//     //         endcase
//     //     end
//     // end

//     // always @ (posedge clk) begin
//     //     if (out_ready) begin
//     //         num_out <= num_out - 1;
//     //     end
//     //     else num_out <= num_out;
//     // end

//     // assign shift_en = num_out == 0?0:1;

// endmodule

