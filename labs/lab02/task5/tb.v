// tb.v
// Self-checking testbench for alu. Covers:
//   - the same operand pair held fixed while op switches (exposes the
//     sensitivity-list bug)
//   - subtraction with several operand pairs (exposes the blocking /
//     non-blocking bug)
//   - an exhaustive sweep of all a, b, op combinations

module tb;

  reg  [3:0] t_a, t_b;
  reg        t_op;
  wire [3:0] t_result;

  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  integer errors = 0;
  integer total  = 0;
  integer i, j, k;
  reg [3:0] exp_res;

  task check;
    begin
      #5;
      exp_res = t_op ? (t_a - t_b) : (t_a + t_b);
      total = total + 1;
      if (t_result !== exp_res) begin
        $display("FAIL at time %0t: a=%0d b=%0d op=%b  got %0d  expected %0d",
                 $time, t_a, t_b, t_op, t_result, exp_res);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    // 1) same operands, switch op only
    t_a = 4'd5; t_b = 4'd3; t_op = 1'b0; check;
    t_op = 1'b1;                         check;
    t_op = 1'b0;                         check;

    // 2) subtraction with changing operands
    t_op = 1'b1;
    t_a = 4'd8;  t_b = 4'd2;  check;
    t_a = 4'd3;  t_b = 4'd7;  check;
    t_a = 4'd15; t_b = 4'd1;  check;

    // 3) addition with changing operands
    t_op = 1'b0;
    t_a = 4'd9;  t_b = 4'd4;  check;
    t_a = 4'd12; t_b = 4'd7;  check;

    // 4) exhaustive sweep
    for (k = 0; k < 2; k = k + 1)
      for (i = 0; i < 16; i = i + 1)
        for (j = 0; j < 16; j = j + 1) begin
          t_op = k[0]; t_a = i[3:0]; t_b = j[3:0];
          check;
        end

    $write("Summary: %0d / %0d passed", total - errors, total);
    $write(", %0d failed\n", errors);
    $finish;
  end

endmodule
