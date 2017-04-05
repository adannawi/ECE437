`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

`timescale 1ns/1ns

module dcache_tb;
	import cpu_types_pkg::*;
	parameter PERIOD = 10;
	logic tb_clk = 1;
	logic tb_nRST;
	int testcase;

	always #(PERIOD/2) tb_clk++;

	caches_if tbcif1(); 
	caches_if tbcif2();
	cpu_ram_if tbrif();
	cache_control_if tbccif(tbcif1, tbcif2);

	datapath_cache_if dif1();
	datapath_cache_if dif2();

	// Connect RAM inputs to Cache Control
	assign tbrif.ramaddr = tbccif.ramaddr;
	assign tbrif.ramstore = tbccif.ramstore;
	assign tbrif.ramREN = tbccif.ramREN;
	assign tbrif.ramWEN = tbccif.ramWEN;
	assign tbccif.ramload = tbrif.ramload;
	assign tbccif.ramstate = tbrif.ramstate;

	// Map the DCache - Fix this to support multicore
	dcache DUT (
		.CLK(tb_clk),
		.nRST(tb_nRST),
		.dcif(dif1),
		.cif(tbcif1)
	);

	dcache dcache2 (
		.CLK(tb_clk),
		.nRST(tb_nRST),
		.dcif(dif2),
		.cif(tbcif2)
	);

	// Map the RAM
	ram dat_ram(
		.CLK(tb_clk),
		.nRST(tb_nRST),
		.ramif(tbrif)
	);

	// Map the Memory Controller

	memory_control memory_control(
		.CLK(tb_clk),
		.nRST(tb_nRST),
		.ccif(tbccif)
	);

///////////////////
//
// Manually set address to 32 bits.
//  [25:0] [2:0]  [1]     [1:0]
//   TAG    IDX  BLKOFF  BYTEOFF                                   
initial begin

	// Need 5 test cases //
	// 1. Test read/write BusRD and BusRDx, see if it snoops other core- if miss, read from memory
	// 2. Test BusRD and BusRDx with cache in modify, see if cache-to-cache transfer happens
	// 3. BusRDx on shared while other core is in shared- it should go to invalid state.
	// 4. If no data is happening, instructions should be able to go through
	// 5. See if instructions are doing fair flipping in datapath
	// 6. Check if evictions happen without coherence (?)

	// Have the testbench act as the two datapaths while using 
	// real memory controller (w/ coherence) and real ram
	// for maximum testing (ideally)

	testcase = 0;
	wait1();
	tb_nRST = 0;
	wait1();
	tb_nRST = 1;
	wait1();

	// Preliminary Test 0:
	// Populate all cache entries to see if they work correctly
	testcase++;
	populate_cache1();
	wait10();

	// This should reset the caches?
	wait1();
	tb_nRST = 0;
	wait1();
	tb_nRST = 1;
	wait1();

	// Assuming the above actually resets the caches, then proceed accordingly
	////// Test Case 1: Check for snoop miss & read from memory ///////
	// Intended behavior to load index 0, tag 000F with 00001111
	testcase++;
	load_cache1(26'h0000, 0, 0, 0, 32'h00001111); 
	wait5();

	// Intended behavior to load index 0, tag 000F with 00001111, but for cache 2
	load_cache2(26'h000F, 0, 0, 0, 32'h00001111);
	wait5();

	// Store to cache 1 from datapath 1, should be in modified state now
	write_to_cache2(26'h00FF, 1, 0, 0, 32'h11110000);
	wait5();



	/////// Test Case 2: Check for cache to cache transfer ///////
	// This should conduct a cache to cache transfer I think (and go to shared)
	testcase++;
	load_cache1(26'h00FF, 1, 0, 0, 32'h01010000);
	wait5();



	/////// Test Case 3: Check for invalidation on write ///////
	// I think this is a BusRdX on shared, cache 2 should go to invalid
	testcase++;
	write_to_cache1(26'h00FF, 1, 0, 0, 32'h0000F00D);
	wait5();


	// If this doesn't work, may have to check if way is being set as intended (and modify testbench)
	/////// Test Case 4: Check if eviction happens ///////
	testcase++;
	write_to_cache1(26'h0001, 1, 0, 0, 32'h0B4DF00D);
	wait5();

end

	// This is a dinky function to test and see if the cache
	// populates right, this may or may not work.

	task populate_cache1();
		begin
		int lcv;
		for (lcv = 0; lcv < 16; lcv++) begin
			load_cache1(lcv*2, lcv%8, 0, 0, 32'h0420F00D);
		end
	end
	endtask

	// This task's purpose is to get data from the cache, and it should go to RAM if the data
	// does not exist. Snooping will be conducted, and on a miss it will go to RAM.
	task load_cache1(
		input logic[25:0] tag,
		input logic[2:0] idx,
		input logic blk_off,
		input logic[1:0] byte_off,
		input word_t data
		);
		begin
		@(negedge tb_clk);
		dif1.dmemaddr = {tag, idx, blk_off, byte_off};
		dif1.dmemREN = 1;
		dif1.dmemWEN = 0;
		tbcif1.dload = data;
		@(posedge tb_clk);
		end
	endtask

	// This task's purpose is to get data from the cache, and it should go to RAM if the data
	// does not exist. Snooping will be conducted, and on a miss it will go to RAM.
	// Difference is that this is for the second cache.
	task load_cache2(
		input logic[25:0] tag,
		input logic[2:0] idx,
		input logic blk_off,
		input logic[1:0] byte_off,
		input word_t data
		);
		begin
		@(negedge tb_clk);
		dif2.dmemaddr = {tag, idx, blk_off, byte_off};
		dif2.dmemREN = 1;
		dif2.dmemWEN = 0;
		tbcif2.dload = data;
		@(posedge tb_clk);
		end
	endtask

	// This task's purpose is to write data to the cache from the datapath, the state should transition to 
	// modified (MSI protocol)
	task write_to_cache1(
		input logic[25:0] tag,
		input logic[2:0] idx,
		input logic blk_off,
		input logic[1:0] byte_off,
		input word_t data
		);
		begin
		@(negedge tb_clk);
		dif1.dmemaddr = {tag,idx, blk_off, byte_off};
		dif1.dmemWEN = 1;
		dif1.dmemREN = 0;
		tbcif1.dstore = data;
		@(posedge tb_clk);
		end
	endtask

	// This task is similar to the previous one with the difference being that this one works with the second
	// cache.
	task write_to_cache2(
		input logic[25:0] tag,
		input logic[2:0] idx,
		input logic blk_off,
		input logic[1:0] byte_off,
		input word_t data
		);
		begin
		@(negedge tb_clk);
		dif2.dmemaddr = {tag,idx, blk_off, byte_off};
		dif2.dmemWEN = 1;
		dif2.dmemREN = 0;
		tbcif2.dstore = data;
		@(posedge tb_clk);
		end
	endtask

	// Wait for 1 cycle, old news, been done before
	task wait1 ();
	    begin
		@(posedge tb_clk);
	    end
	endtask

	// Wait for 5 cycles
	task wait5 ();
		begin
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		@(posedge tb_clk);
		end
	endtask

	// 10 cycles obviously
	task wait10 ();
		begin
			wait5();
			wait5();
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

        tbcif1.daddr = i << 2;
        tbcif1.dREN = 1;
        repeat (4) @(posedge tb_clk);
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
        tbcif1.dREN = 0;
        $fdisplay(memfd,":00000001FF");
        $fclose(memfd);
        $display("Finished memory dump.");
      end
    endtask

endmodule // dcache_tb
