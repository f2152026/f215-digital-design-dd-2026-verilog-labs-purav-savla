// tb.v
// Testbench for the 2-to-1 mux: applies all 8 combinations of I0, I1, S,
// 5 time units apart, and checks Y against the expected value.

module tb;

  // DUT inputs are driven from procedural code, so they are variables (reg).
  reg   t_i0, t_i1, t_s;
  // DUT output is driven by the DUT's port, so it is a net (wire).
  wire  t_y;

  DUT DUT (
    .I0 (t_i0),
    .I1 (t_i1),
    .S  (t_s),
    .Y  (t_y)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  integer i;
  integer errors = 0;

  initial begin
    for (i = 0; i < 8; i = i + 1) begin
      {t_i0, t_i1, t_s} = i[2:0];
      #5;
      if (t_y !== (t_s ? t_i1 : t_i0)) begin
        $display("FAIL: I0=%b I1=%b S=%b got Y=%b", t_i0, t_i1, t_s, t_y);
        errors = errors + 1;
      end
    end
    $display("%0d / 8 combinations passed", 8 - errors);
    $finish;
  end

  initial
    $monitor($time, " I0=%b I1=%b S=%b | Y=%b", t_i0, t_i1, t_s, t_y);

endmodule
