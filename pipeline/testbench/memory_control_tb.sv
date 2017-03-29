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
  int Test_Case;

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
    initialize_values();
    wait1();
    //Initialize values
/*
    tbccif.iREN = 0;
    tbccif.dWEN = 0;
    tbccif.dREN = 0;
    tbccif.dstore = 0;
    tbccif.iaddr = 0;
    tbccif.daddr = 0;
*/




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

    //Instruction Assertions only
    
    //Test Case 1
    //Assert processor 1, test that instruction is gotten right
    Test_Case = 1;
    P1_read_instr(32'h0000FF04);
    receive_P1_instr();

    //Test Case 2
    //Assert other processor, check that imstruction is gotten right
    
    Test_Case = 2;
    P2_read_instr(32'h0000FF00);
    receive_P2_instr();
    


    //Test Case 3
    //Assert both instruction requests, should prioritize 1
    //Once done, keep 1's asserted to check that two then one
    //are done in the correct order to test the round-robin system
   
    Test_Case = 3;
    
    //Assert both instructions simulataneously
    P1_read_instr(32'h0000FF08);
    P2_read_instr(32'h0000FF0C);

    //This will hang if iwait for correct processor does not go low
    receive_P1_instr();
    receive_P2_instr();
    wait1();
    //Data without Coherence
    //Useful for write back at end since values will get invalidated
    //without setting cctrans (I think)

    //Test Case 4
    //Assert processor 1, test that data is gotten right
    Test_Case = 4;
    P1_write_data(32'h0000FF10, 32'hDEAD0000, 32'h0000BEEF);


    //Test Case 5
    wait1();
    Test_Case = 5;
    //Assert other processor, check that data is gotten right
    P2_write_data(32'h0000FF18, 32'hECE00000, 32'h00043700);

    //Test Case 6
    wait1();
    Test_Case = 6;
    //Assert both data Write requests, should prioritize 1
    //Once done, keep 1's asserted to check that two then one
    //are done in the correct order to test tsim:/memory_control_tb/DUT/ccif/ramREN
    //he round-robin system
    //Get one starting address, same data gets written to each
    P1P2_write_data(32'h0000FF20, 32'hDEADBEEF, 32'hECE43700);


    //Coherence Testing

    //Basic Test Cases

    //Test Case 7
    //Test a Write from P1 where P2 asserts ccwrite to indicate that
    //it has the data and writes back.
    //  Need to supply:
    //    Data "from" P2
    //    Write signals "from" P2 
    wait1();
    Test_Case = 7;
    coherence_ctc(32'h0000FF30,0); //This will be for 2 addresses
    

    //Test Case 8
    //Test a Write from P1 where P2 does not assert ccwrite to indicate that
    //it does not have the data and writes back. 
    wait1();
    Test_Case = 8;
    coherence_mem(32'h0000FF38,0);

    //Coherence Round Robin

    //Test Case 9
    wait1();
    Test_Case = 9;
    //Repeat 7 & 8 At the same time



    //Prioritizing Data

    //Test Case 10
    //Test that data beats instruction
    wait1();
    Test_Case = 10;


    wait10();

    dump_memory();

    //Dump memory after a few loads
    $finish();
  end
  

  task rwr();
  begin
    //Reads value at location, writes, checks that the value is right
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
      tb_nRST = 1; //Reset iREN so it "does" something
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




  task coherence_ctc(input word_t address, input logic target);
    begin
      //Do for dWEN, dREN would just always be more or less the same
      //Just ends up in different implied state
      if (target) begin
        tbc2.dREN = 1;
        tbc2.daddr = address; //This should be same as ccsnoopaddr
        tbc2.cctrans = 1;
      end else begin
        tbc1.dREN = 1;
        tbc1.daddr = address; //This should be same as ccsnoopaddr
        tbc1.cctrans = 1;
      end
       
      //Wait for arbitrate state
      @(posedge tb_CLK)
      
      //Say other processor has data
      if (target) begin
        tbc1.ccwrite = 1;
      end else begin
        tbc2.ccwrite = 1;
      end
      //Wait for CTC1
      @(posedge tb_CLK)
      if (target) begin
        tbc1.daddr = 1;
        tbc1.dstore = 32'hDEAD0000;
      end else begin
        tbc2.daddr = 1;
        tbc2.dstore = 32'hDEAD0000;
      end
      //Wait for data to be written back
      @(negedge tbccif.dwait[~target]);
      if (target) begin
        tbc1.daddr = 1;
        tbc1.dstore = 32'h0000BEEF;
      end else begin
        tbc2.daddr = 1;
        tbc2.dstore = 32'h0000BEEF;
      end
      //Wait for data to be written back
      @(negedge tbccif.dwait[~target]);
      tbc2.dstore = 0;
      tbc2.daddr = 0;
      tbc2.dREN = 0;
      tbc1.dstore = 0;
      tbc1.daddr = 0;
      tbc1.dREN = 0;
      tbccif.cctrans[target] = 0;
      tbccif.ccwrite[~target] = 0;
    end
  endtask

  task coherence_mem(input word_t address,input logic target);
    begin
      //Do for dWEN, dREN would just always be more or less the same
      //Just ends up in different implied state
      if (target) begin
        tbc2.dREN = 1;
        tbc2.daddr = address; //This should be same as ccsnoopaddr
        tbc2.cctrans = 1;
      end else begin
        tbc1.dREN = 1;
        tbc1.daddr = address; //This should be same as ccsnoopaddr
        tbc1.cctrans = 1;
      end
      
      //tbccif.cctrans[target] = 1;
      //daddr = address; //This should be same as ccsnoopaddr
      //Wait for arbitrate state
      @(posedge tb_CLK);
      
      //Say other processor has data


      //Wait for CTC1
      @(posedge tb_CLK);

      //Wait for data to be written back
      @(negedge tbccif.dwait[~target]);

      //Wait for data to be written back
      @(negedge tbccif.dwait[~target]);
      tbc2.dstore = 0;
      tbc2.daddr = 0;
      tbc2.dWEN = 0;
      tbc1.dstore = 0;
      tbc1.daddr = 0;
      tbc1.dWEN = 0;
      tbccif.cctrans[target] = 0;
      tbccif.ccwrite[~target] = 0;
    end
  endtask

  task initialize_values();
    begin
      //Since RAM is actually used, we can just set the signals
      //coming from the processors (generated by dcache, icache in reality)
      //for a more realistic imulation

      //Set cache-side memory control signals
      tbc1.iREN = 0;
      tbc1.dWEN = 0;
      tbc1.dREN = 0;
      tbc1.dstore = 0;
      tbc1.iaddr = 0;
      tbc1.daddr = 0;
      tbc1.ccwrite = 0;
      tbc1.cctrans = 0;
      //Coherehence from Processors
      tbc2.iREN = 0;
      tbc2.dWEN = 0;
      tbc2.dREN = 0;
      tbc2.dstore = 0;
      tbc2.iaddr = 0;
      tbc2.daddr = 0;
      tbc2.ccwrite = 0;
      tbc2.cctrans = 0;

      //Ram inputs will be set by ram instantiation for TB
    end
  endtask

  /////////////////////////////////////////////////////////
  //PROCESSOR 1 INSTRUCTION REN
  task P1_read_instr(
    input word_t address
    );
    begin
    //Target all read assertions to processor 1 signals
    //@(posedge tb_CLK)
    //Setup values to read from mem
    tbc1.iREN = 1;
    tbc1.iaddr = address;
    end
  endtask

  //Use when expecting to have an instruction given by mem
  task receive_P1_instr();
    begin
    //Target all read assertions to processor 1 signals
    @(negedge tbc1.iwait)
    #(1);
    @(posedge tb_CLK)

    //Reset iREN and iaddr since request is "done"
    tbc1.iREN = 0;
    tbc1.iaddr = 0;
    end
  endtask


  //PROCESSOR 2 INSTRUCTION REN
  //Use to assert an instruction request
  //Does not need to be constantly set with caches, but may be
  task P2_read_instr(
    input word_t address
    );
    begin
    //Target all read assertions to processor 1 signals
    //@(posedge tb_CLK)
    //Setup values to read from mem
    tbc2.iREN = 1;
    tbc2.iaddr = address;
    end
  endtask

  //Use when expecting to have an instruction given by mem
  task receive_P2_instr();
    begin
    //Target all read assertions to processor 1 signals
    @(negedge tbc2.iwait);
    #(1);
    @(posedge tb_CLK);

    //Reset iREN and iaddr since request is "done"
    tbc2.iREN = 0;
    tbc2.iaddr = 0;
    end
  endtask

  //P1 Write Block
  task P1_write_data(input word_t address, input word_t data1, input word_t data2);
    begin
      //Initialize data to write
      tbc1.dWEN = 1;
      tbc1.daddr = address;
      tbc1.dstore = data1;
      @(negedge tbccif.dwait[0]);
      @(posedge tb_CLK);
      tbc1.daddr = address + 4;
      tbc1.dstore = data2;
      @(negedge tbccif.dwait[0]);
      @(posedge tb_CLK);
      tbc1.dWEN = 0;
      tbc1.daddr = 0;
      tbc1.dstore = 0;
    end
  endtask

  //P2 Write Block
  task P2_write_data(input word_t address, input word_t data1, input word_t data2);
    begin
      //Initialize data to write
      tbc2.dWEN = 1;
      tbc2.daddr = address;
      tbc2.dstore = data1;
      @(negedge tbccif.dwait[1]);
      //@(posedge tb_CLK);
      tbc2.daddr = address + 4;
      tbc2.dstore = data2;
      //@(negedge tbccif.dwait[1]);
      //@(posedge tb_CLK);
      tbc2.dWEN = 0;
      tbc2.daddr = 0;
      tbc2.dstore = 0;
    end
  endtask

  task P1P2_write_data(input word_t address,input word_t data1,input word_t data2);
    begin
        //Assert all at once
        tbc1.dWEN = 1;
        tbc1.daddr = address;
        tbc1.dstore = data1;
        tbc2.dWEN = 1;
        tbc2.daddr = address;
        tbc2.dstore = data1;
        write_delay_p1();
        //Change P1's data
        tbc1.daddr = address + 4;
        tbc1.dstore = data2;

        write_delay_p1();

        //Reset P1
        tbc1.dWEN = 0;
        tbc1.daddr = 0;
        tbc1.dstore = 0;

        //Now that P1 is done wait for P2
        write_delay_p2();
        tbc2.daddr = address + 12;
        tbc2.dstore = data2;

        write_delay_p2();

        //Reset P1
        tbc2.dWEN = 0;
        tbc2.daddr = 0;
        tbc2.dstore = 0;

    end
  endtask

  task write_delay_p1 ();
    begin
    @(negedge tbc1.dwait);
    @(posedge tb_CLK);
    tb_nRST = 1;
    end
  endtask

  task write_delay_p2 ();
    begin
    @(negedge tbc2.dwait);
    @(posedge tb_CLK);
    tb_nRST = 1;
    end
  endtask



  /////////////////////////MISC TASKS/////////////////////////

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


  //Predefined tasks
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
endmodule
