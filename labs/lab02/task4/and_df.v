// and_df.v
// 2-input AND gate, DATAFLOW style, with a continuous-assignment delay.
// Delay values tried: #3 (4a), #2 (4b), #3 (4c). Final value: #3.

module and_df (
  input  a,
  input  b,
  output y
);

  assign #3 y = a & b;

endmodule

