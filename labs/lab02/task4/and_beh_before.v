// and_beh_before.v
// 2-input AND gate, BEHAVIORAL style, delay placed BEFORE the assignment:
// wait first, then evaluate a & b with whatever values exist at that time.
// Delay values tried: #3 (4a), #2 (4b), #3 (4c). Final value: #3.

module and_beh_before (
  input      a,
  input      b,
  output reg y
);

  always @(*) begin
    #3 y = a & b;
  end

endmodule
