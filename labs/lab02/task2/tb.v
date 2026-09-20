// tb.v
// Testbench for the parameterized ROM (lut). Instantiates lut with a
// parameter override (WIDTH=8, DEPTH=8) and checks every address against
// the expected value i*i.

module tb;

  // 3 bits of select covers DEPTH = 8
  reg  [2:0] t_sel;
  wire [7:0] t_dout;

  lut #(.WIDTH(8), .DEPTH(8)) DUT (
    .sel  (t_sel),
    .dout (t_dout)
  );

  // Waveform dump configuration (DO NOT CHANGE)
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
    #1;  // let the ROM's initial block load mem[] before the first read
    for (i = 0; i < 8; i = i + 1) begin
      t_sel = i[2:0];
      #5;
      if (t_dout !== i * i) begin
        $display("FAIL at sel=%0d: got %0d, expected %0d", i, t_dout, i * i);
        errors = errors + 1;
      end
    end
    $display("%0d / 8 addresses passed", 8 - errors);
    $finish;
  end

  initial
    $monitor($time, " sel=%0d | dout=%0d", t_sel, t_dout);

endmodule
