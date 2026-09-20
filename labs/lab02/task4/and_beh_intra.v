// and_beh_intra.v
// 2-input AND gate, BEHAVIORAL style, INTRA-assignment delay:
// evaluate a & b now, write the result into y after the delay.
// Delay values tried: #3 (4a), #2 (4b), #3 (4c). Final value: #3.

module and_beh_intra (
  input      a,
  input      b,
  output reg y
);

  always @(*) begin
    y = #3 a & b;
  end

endmodule
