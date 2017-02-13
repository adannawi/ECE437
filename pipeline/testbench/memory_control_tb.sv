/*
  Noah Petersen
  peter248

  MEM CTRLLR TB
*/

`include "cache_control_if.vh"
`include "cpu_types_pkg.vh"
`include "cpu_ram_if.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;
//import cache_control_if::*;
//import cpu_ram_if::*;

module memory_control_tb;

  parameter PERIOD = 20;
  logic tb_CLK = 1;

  //Clock
  always #(PERIOD/2) tb_CLK++;

  //RAM loaded with most recently asm'd file.
  //DUMP ram in system testbench

  //Memory Control Test Variables
  /*
  logic tb_ramWEN,tb_ramREN, tb_iREN, tb_dREN, tb_dWEN;
  logic tb_nRST, tb_iwait, tb_dwait;
  ramstate_t tb_ramstate;
  word_t tb_iload, tb_dload, tb_dstore, tb_iaddr, tb_daddr, tb_ramaddr;
  word_t tb_ramstore, tb_ramload;
  */
  //Declare ifs
  logic tb_nRST;

  cpu_ram_if tbrif();
  caches_if tbc1();
  caches_if tbc2();

  cache_control_if tbccif(tbc1,tbc2);

  //Connect signals for if

  //  RAM INPUT Connected to Cache control
  //ramaddr, ramstore,ramREN, ramWEN
assign tbrif.ramaddr = tbccif.ramaddr;
assign tbrif.ramstore = tbccif.ramstore;
assign tbrif.ramREN = tbccif.ramREN;
assign tbrif.ramWEN = tbccif.ramWEN;

assign tbccif.ramload = tbrif.ramload;
assign tbccif.ramstate = tbrif.ramstate;
  //  Ram OUTPUT
  //ramstate, ramload

  //  Cache control signals
  //Inputs need tb variables assigned
/*
assign tbccif.iREN =
assign tbccif.dREN =
assign tbccif.dWEN =
assign tbccif.dstore =
assign tbccif.iaddr =
assign tbccif.darrd =
assign tbccif.ramload =
assign tbccif.ramstate =
*/
  //Outputs (read)
/*
assign = tbccif.iwait;
assign = tbccif.dwait;
assign = tbccif.ramWEN;
assign = tbccif.ramREN;
*/


  memory_control DUT(
      .CLK(tb_CLK),
      .nRST(tb_nRST),
      .ccif(tbccif)
  );

  //RAM module
  ram dat_ram (
      .CLK(tb_CLK), //DOES THIS NEED TO BE A SEPERATE CLOCK?
      .nRST(tb_nRST),
      .ramif(tbrif)
    );
  //Test Cases
  initial begin
    //Show that dREN or dWEN are prioritized over iREN
    /* Inputs to set
      tbccif.iREN
      tbccif.dWEN
      tbccif.dREN
      tbccif.dstore
      tbccif.iaddr
      tbccif.daddr
    */
    wait1();
    tb_nRST = 0;
    wait1();
    tb_nRST = 1;

    //Initialize values
/*
    tbccif.iREN = 0;
    tbccif.dWEN = 0;
    tbccif.dREN = 0;
    tbccif.dstore = 0;
    tbccif.iaddr = 0;
    tbccif.daddr = 0;
*/
    tbc1.iREN = 0;
    tbc1.dWEN = 0;
    tbc1.dREN = 0;
    tbc1.dstore = 0;
    tbc1.iaddr = 0;
    tbc1.daddr = 0;
    wait5();
/*
    //Test to see whether dWEN or iREN superceds the other
    tbc1.iREN = 1;
    //tbc1.dWEN = 1;
    tbc1.dREN = 1;
    tbc1.iaddr = 32'h00000000;
    tbc1.daddr = 32'h00000000;
    tbc1.dstore = 32'h000000FF;
    wait2();
  */
    //testcase 1
    //set values
    tbc1.iaddr = 32'h00000000;
    tbc1.daddr = 32'h00000000;
    tbc1.dstore = 32'h000000ff;

    rwr();

    //testcase 2
    //set values
    tbc1.iaddr = 32'h00000000;
    tbc1.daddr = 32'h00000004;
    tbc1.dstore = 32'h0000ff00;

    rwr();

    //testcase 3
    //set values
    tbc1.iaddr = 32'h00000000;
    tbc1.daddr = 32'h00000008;
    tbc1.dstore = 32'h00ff0000;

    rwr();

    //testcase 4
    //set values
    tbc1.iaddr = 32'h00000000;
    tbc1.daddr = 32'h0000000C;
    tbc1.dstore = 32'hff000000;

    rwr();

    //testcase 5
    //set values
    tbc1.iaddr = 32'h00000000;
    tbc1.daddr = 32'h00000010;
    tbc1.dstore = 32'hffffffff;

    rwr();

    tbc1.dREN = 0;
    tbc1.dWEN = 0;


    wait10();

    dump_memory();

    //Dump memory after a few loads
    $finish();
  end
  //Tasks

    //Taken from system testbench provided for single-cycle
    task automatic dump_memory();
      string filename = "memcpu.hex";
      int memfd;

      //syif.tbCTRL = 1; // I think that tbCTRL is not needed
      //tbccif.dstore = 0;
      //tbccif.dWEN = 0;
      //tbccif.dREN = 0;

      memfd = $fopen(filename,"w");
      if (memfd)
        $display("Starting memory dump.");
      else
        begin $display("Failed to open %s.",filename); $finish; end

      for (int unsigned i = 0; memfd && i < 16384; i++)
      begin
        int chksum = 0;
        bit [7:0][7:0] values;
        string ihex;

        tbc1.daddr = i << 2;
        tbc1.dREN = 1;
        repeat (4) @(posedge tb_CLK);
        if (tbccif.ramstore === 0)
          continue;
        values = {8'h04,16'(i),8'h00,tbccif.ramstore}; //originally .ramstore, tried .dstore
        foreach (values[j])
          chksum += values[j];
        chksum = 16'h100 - chksum;
        ihex = $sformatf(":04%h00%h%h",16'(i),tbccif.ramstore,8'(chksum));
        $fdisplay(memfd,"%s",ihex.toupper());
      end //for
      if (memfd)
      begin
        //syif.tbCTRL = 0;
        tbc1.dREN = 0;
        $fdisplay(memfd,":00000001FF");
        $fclose(memfd);
        $display("Finished memory dump.");
      end
    endtask

  task rwr();
  begin
    //read value
    tbc1.dREN = 1;
    tbc1.dWEN = 0;

    waitforload();
    @(negedge tb_CLK);
    //write
    tbc1.dREN = 0;
    tbc1.dWEN = 1;

    @(posedge tb_CLK);
    waitforload();
    @(negedge tb_CLK);
    //check
    tbc1.dREN = 1;
    tbc1.dWEN = 0;

    waitforload();
    @(negedge tb_CLK);

  end
  endtask

  task wait1();
  begin
    @(posedge tb_CLK);
    tbc1.iREN = 1; //Reset iREN so it "does" something
  end
  endtask

  task waitforload();
  begin
    @(negedge tbc1.dwait);
    tbc1.iREN = 1;
  end
  endtask

  task waitforram();
  begin
    if(tbccif.ramstate == ACCESS) begin
      tbc1.iREN = 1;
    end else begin
      wait1();
    end
  end
  endtask

  task wait2();
  begin
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    tbc1.iREN = 1;
  end
  endtask

  task wait5();
  begin
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    tbc1.iREN = 1;
  end
  endtask

  task wait10();
  begin
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    @(posedge tb_CLK);
    tbc1.iREN = 1;
  end
  endtask
endmodule
