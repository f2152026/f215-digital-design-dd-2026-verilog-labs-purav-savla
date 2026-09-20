`timescale 1ns/1ps


module lcu16(
  input  [15:0] g_blk,
  input  [15:0] p_blk,
  input         cin,
  output [15:0] c_blk,
  output        cout
);

  wire [16:0] c;

  assign c[0] = cin;

  // Parallel lookahead carry expansion across all 16 block inputs
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : carry_chain
      assign #2 c[i+1] = g_blk[i] | (p_blk[i] & c[i]);
    end
  endgenerate

  assign c_blk = c[15:0];
  assign cout  = c[16];

endmodule

module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  wire [15:0] g_blk, p_blk;
  wire [15:0] c_blk;

  // Second-level Lookahead Unit
  lcu16 lcu_inst (
    .g_blk(g_blk),
    .p_blk(p_blk),
    .cin(cin),
    .c_blk(c_blk),
    .cout(cout)
  );

  // Instantiate 16 Level-1 CLA4 blocks (using existing cla4 module)
  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : cla_blocks
      cla4 block_inst (
        .a(a[4*k + 3 : 4*k]),
        .b(b[4*k + 3 : 4*k]),
        .cin(c_blk[k]),
        .sum(sum[4*k + 3 : 4*k]),
        .g_blk(g_blk[k]),
        .p_blk(p_blk[k])
      );
    end
  endgenerate

endmodule