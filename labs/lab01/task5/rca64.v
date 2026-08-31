`timescale 1ns/1ps

module rca64(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // Internal carry chain vector (bit 0 is cin, bit 64 is final cout)
  wire [64:0] c;

  // Connect initial carry-in
  assign c[0] = cin;

  // Generate loop to instantiate 64 FA_Gate modules
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_fa
      FA_Gate FA (
        .a   (a[i]),
        .b   (b[i]),
        .cin (c[i]),
        .sum (sum[i]),
        .cout(c[i+1])
      );
    end
  endgenerate

  // Connect final carry-out
  assign cout = c[64];

endmodule