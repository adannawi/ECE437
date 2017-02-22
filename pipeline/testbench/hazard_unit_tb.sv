// Ziad Dannawi
// Test bench for hazard/forward unit
//

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
    hutb.rs_f = 0;
    hutb.rt_f = 0;
    hutb.ALUSrc = 0;
    hutb.wbDest = 0;
    hutb.writeReg_wb = 0;
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

    // Forwarding test case
    @(negedge CLK);
    hutb.ALUSrc = 0;
    hutb.wbDest = 1;
    hutb.rt_f = 1;
    hutb.writeReg_wb = 1; // Should give B_fw = 10
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);
    @(negedge CLK);
    hutb.rs_f = 1; // Should give A_fw = 10
    @(posedge CLK);
  end

  endprogram

