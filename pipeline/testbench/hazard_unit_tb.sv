`include "hazard_unit_if.vh"
`timescale 1 ns / 1 ns

module hazard_unit_tb;
  parameter PERIOD = 10;
  logic CLK = 0;
  logic nRST;

  always #(PERIOD/2) CLK++;

  hazard_unit_if huif ();
  test PROG (CLK, nRST, huif);
  hazard_unit DUT (CLK, nRST, huif);
  endmodule


  program test
  (
    input logic CLK,
    output logic nRST,
    hazard_unit_if.tb hutb
  );

  initial begin
    @(negedge CLK);
    hutb.rs = 0;
    hutb.rt = 0;
    hutb.execDest = 0;
    hutb.memDest = 0;
    hutb.MemRead_Ex = 0;
    hutb.MemRead_Mem = 0;
    hutb.ihit = 0;
    hutb.dhit = 0;
    hutb.branch = 0;
    @(posedge CLK);
    @(posedge CLK);

    // Check for execute flush
    @(negedge CLK);
    hutb.dhit = 1;
    @(posedge CLK);
    hutb.dhit = 0;

    // Check for RAW hazard
    @(posedge CLK);
    @(negedge CLK);
    hutb.rs = 3;
    hutb.rt = 4;
    hutb.execDest = 3;
    hutb.memDest = 4;
    @(posedge CLK);
    @(posedge CLK);
  end

  endprogram

