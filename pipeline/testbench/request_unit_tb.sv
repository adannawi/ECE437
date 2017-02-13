/*
    Noah Petersen

    Request Unit Testbench

    Testbench for single cycle request unit.
*/
`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module request_unit_tb;

  //Clock Declaration
  parameter PERIOD = 20;
  logic CLK = 1;

  always #(PERIOD/2) CLK++;

  //Test Interface
  //request_unit_if ruif();
  request_unit_if ruif();
  logic nRST;

`ifndef MAPPED
  //DUT
  request_unit DUT(
      .CLK(CLK),
      .nRST(nRST),
      .ruif(ruif)
    );
`else
  request_unit DUT(
      .\CLK (CLK),
      .\nRST (nRST),
      .\ruif.dreadreq (ruif.dreadreq),
      .\ruif.dwritereq (ruif.dwritereq),
      .\ruif.ireadreq (ruif.ireadreq),
      .\ruif.ihit (ruif.ihit),
      .\ruif.dhit (ruif.dhit),
      .\ruif.dREN (ruif.dREN),
      .\ruif.dWEN (ruif.dWEN),
      .\ruif.iREN (ruif.iREN)
    );
`endif

  initial begin
    ruif.dreadreq = 0;
    ruif.dwritereq = 0;
    ruif.ireadreq = 0;
    ruif.dhit = 0;
    ruif.ihit = 0;

    wait1();
    resetdut();
    wait1();
    ruif.ireadreq = 1;

    //Short delay tests
    wait1();
    ruif.ihit = 1;
    @(negedge CLK);
    ruif.dreadreq = 1;
    wait1();
    ruif.ihit = 0;
    @(negedge CLK);
    ruif.dhit = 1;
    wait1();
    ruif.dreadreq = 0;
    @(negedge CLK);
    ruif.dhit = 0;

    wait1();
    ruif.ihit = 1;
    @(negedge CLK);
    ruif.dwritereq = 1;
    wait1();
    ruif.ihit = 0;
    @(negedge CLK);
    ruif.dhit = 1;
    wait1();
    ruif.dwritereq = 0;
    @(negedge CLK);
    ruif.dhit = 0;

    //Longer delay tests
    wait1();
    ruif.ihit = 1;
    @(negedge CLK);
    ruif.dreadreq = 1;
    wait1();
    ruif.ihit = 0;
    wait1();
    wait1();
    @(negedge CLK);
    ruif.dhit = 1;
    wait1();
    ruif.dreadreq = 0;
    @(negedge CLK);
    ruif.dhit = 0;

    wait1();
    ruif.ihit = 1;
    @(negedge CLK);
    ruif.dwritereq = 1;
    wait1();
    ruif.ihit = 0;
    wait1();
    wait1();
    @(negedge CLK);
    ruif.dhit = 1;
    wait1();
    ruif.dwritereq = 0;
    @(negedge CLK);
    ruif.dhit = 0;


    $finish;
  end

  task wait1();
  begin
  @(posedge CLK);
  nRST=1;
  end
  endtask

  task resetdut();
  begin
    nRST = 1;
    @(posedge CLK);
    nRST = 0;
    @(posedge CLK);
    nRST = 1;
    @(posedge CLK);
  end
  endtask
endmodule
