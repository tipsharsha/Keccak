
// `include "round.v"
// `include "rconst.v"

module f_permutation(mode,clk, reset, in, in_ready, ack, out, out_ready,squeeze);
    input               clk, reset;
    input      [1343:0]  in;
    input               in_ready;
    output              ack;
    output reg [1599:0] out;
    output reg          out_ready;
    input[1:0] mode;
    input squeeze;

    reg        [22:0]   i; /* select round constant */
    reg       [1599:0] round_in;
    wire [1599:0] round_out; 
    wire       [63:0]   rc; /* round constant */
    wire                update;
    wire                accept;
    reg                 calc; /* == 1: calculating rounds */

    assign accept = in_ready & (~ calc); // in_ready & (i == 0)
    
    always @ (posedge clk)
      if (reset) i <= 0;
      else       i <= {i[21:0], accept|squeeze};
    
    always @ (posedge clk)
      if (reset) calc <= 0;
      else       calc <= (calc & (~ i[22])) | accept;
    
    assign update = calc | accept;

    assign ack = accept;

    always @ (posedge clk)
      if (reset)
        out_ready <= 0;
      else if (accept)
        out_ready <= 0;
      else if (i[22]) // only change at the last round
        out_ready <= 1;

    // assign round_in = accept ? {in ^ out[1599:1599-575], out[1599-576:0]} : out;

    always @ (*) begin
      if (accept) begin
        case(mode)
          0: round_in = {in[1343-:576] ^ out[1599:1599-575], out[1599-576:0]};
          1: round_in = {in[1343-:1088] ^ out[1599:1599-1087], out[1599-1088:0]};
          2: round_in = {in ^ out[1599:1599-1343], out[1599-1344:0]};
          3: round_in = {in[1343-:1088] ^ out[1599:1599-1087], out[1599-1088:0]};
        endcase
      end
      else begin
        round_in =out;
      end
    end

    rconst
      rconst_ ({i, accept}, rc);

    round
      round_ (round_in, rc, round_out);

    always @ (posedge clk)
      if (reset)
        out <= 0;
      else if (update)
        out <= round_out;
endmodule
