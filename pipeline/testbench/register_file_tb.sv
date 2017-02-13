/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "register_file_if.vh"

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module register_file_tb;

  parameter PERIOD = 10;

  logic CLK = 0, nRST;
  int testcase;
  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock
  always #(PERIOD/2) CLK++;

  // interface
  register_file_if rfif ();

  // test program
  test PROG (
    .CLK(CLK),
    .nRST(nRST),
    .rftbif(rfif),
    .testcase(testcase)
);
  // DUT
`ifndef MAPPED
  register_file DUT(CLK, nRST, rfif);
`else
  //Would this already define the DUT? Or does it need to be done in the program
  register_file DUT(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),

    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif
    //.\rfif.wdat (rfif.wdat),

/*
    //TB variable declaration
   register_file_if tbif

    //DUT Connection
    register_file DUT(); //<-Doing this in program
*/

endmodule


/////////////////////////////////////////////////////////////
//How/where to define DUT
//How/where to define interface


/*
  Test Cases:
    Simple Read/Write (For Reg0 and not Reg0 with nonzero WDAT)
    Write to ALL Registers (something like an increasing value
    Read all Registers
    Verify RDAT1 & RDAT2 work the same
*/

program test
(
  input logic CLK,
  register_file_if.tb rftbif,
  output logic nRST,
  output int testcase
);
//  register_file_if tbif ();
//  register_file_if rfif ();
//  logic tb_CLK;
  int i;
//Test Cases
  initial begin
    //Set tb signal start values
    /*
    tbif.WEN = 0;
    tbif.wsel = 0;
    tbif.rsel1 = 0;
    tbif.rsel2 = 0;
    tbif.wdat = 0;
  */
    rftbif.WEN = 0;
    rftbif.wsel = 0;
    rftbif.rsel1 = 0;
    rftbif.rsel2 = 0;
    rftbif.wdat = 0;

    ResetDUT();
    //Output signals to verify inputs with:
    //rdat1
    //rdat2

    testcase = 0;
    @(posedge CLK);

    //Test Case 01: Simple Write to Reg0 & Reg1, Read to Verify
    newtestcase();
    WriteToReg(0,32'hFFFFFFFF);
    CheckValue(0,32'hFFFFFFFF);

    WriteToReg(1,32'hFFFFFFFF);
    CheckValue(1,32'hFFFFFFFF);

    //Test Case 02: Write to all, Read to verify with RDAT1 & RDAT2 separately
    //newtestcase();
    for (i = 0; i < 32; i = i + 1) begin
      WriteToReg(i,32'hFFFFFFFF);
      CheckValue(i,32'hFFFFFFFF);
    end

    //Test Case 03: Write to All, Max value (0xFFFFFFFF)
    //newtestcase();

    //Test Case 04: Write to All, Min value (0x00000000)
    //newtestcase();

    //$finish;
  end

//Original EndProgram
//endprogram

//Verify Reg Value Task
  task CheckValue (
      input [4:0] target,
      input [31:0] ExpVal
    );
    begin
      rftbif.rsel1 = target;
      @(posedge CLK);
      if((target == 0) && (rftbif.rdat1 != 0))  begin
        $error("Error: Register 0 was changed to not 0 in Testcase %d",testcase);
      end else if(rftbif.rdat1 != ExpVal) begin
        $error("Error: Target Register %d does not match expected value in Testcase %d",target,testcase);
      end
      @(posedge CLK);
      rftbif.rsel1 = 0;
      @(posedge CLK);
    end
  endtask

//Write to Register Task
  task WriteToReg (
    input [4:0] target,
    input [31:0] value
  );
    begin
      @(posedge CLK);
      rftbif.WEN = 1;
      rftbif.wsel = target;
      rftbif.wdat = value;
      @(posedge CLK);
      rftbif.WEN = 0;
      rftbif.wsel = '0;
      rftbif.wdat = '0;
      @(posedge CLK);
    end
  endtask

//New Testcase task
  task newtestcase;
    begin
      testcase += 1;
      $info("Running Testcase number %d",testcase);
      @(posedge CLK);
    end
  endtask

//Reset DUT Task
  task ResetDUT;
    begin
      nRST = 0;
      @(posedge CLK);
      @(negedge CLK);
      nRST = 1;
      @(posedge CLK);
      //$finish;
    end
  endtask

//Endprogram for including task(s)
  //$finish;
endprogram
