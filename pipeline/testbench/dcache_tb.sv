`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

`timescale 1ns/1ns

module dcache_tb;
	import cpu_types_pkg::*;
	parameter PERIOD = 10;
	logic CLK = 1;
	logic nRST;

	always #(PERIOD/2) CLK++;

	caches_if cif (); 
	datapath_cache_if dif ();
	//test PROG (CLK, nRST, cif, dif);
	dcache DUT (CLK, nRST, dif, cif);

	//tb signals to set for "datapath": halt, dmemREN, dmemWEN, dmemstore, dmemaddr,
    //tb signals to read 'from' "datapath":  dhit, dmemload, flushed

    //tb signals to set for "mem control": dload, dwait
    //tb signals to read for "mem control": dREN, dWEN, daddr, dstore


//program test
	//(
		//input logic CLK,
		//output logic nRST,
		//caches_if cif,
		//datapath_cache_if dif
	//);


///////////////////
// 1. Initial miss
// 2. Hits
// 3. LRU
// 4. LRU Replacement
// 5. Writes/Reads
// 6. Capacity
///////////////////
//
// Manually set address to 32 bits.
//  [25:0] [2:0]  [1]     [1:0]
//   TAG    IDX  BLKOFF  BYTEOFF                                   
initial begin
	logic [25:0] tbtag;
	logic [2:0] tbidx;
	logic tbblkoff;
	logic [1:0]tbbyteoff;
	integer i;
	integer testcase;

	@(negedge CLK);
	nRST = 0;
	@(posedge CLK);
	@(negedge CLK);
	nRST = 1;
	@(posedge CLK);

	///////////////////////
	//Test 0:
	//Populate the cache
	///////////////////////
	testcase = 0;
	for(i = 0; i < 16; i++) begin
	tbtag = i * 2;
	tbidx = i % 8;
	tbblkoff = 0;
	tbbyteoff = 0;
	dif.dmemaddr = {tbtag, tbidx, tbblkoff, tbbyteoff};
	dif.dmemstore = 32'hDEADBEEF;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = (i < 8) ? 32'hece43700 : 32'hcadacada;

	@(posedge dif.dhit); // dhit??
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;
	end // for(i = 0; i < 8; i++)

	///////////////////////
	//Test 1:
	//Load into set 0
	///////////////////////
	testcase++;
	dif.dmemaddr = 32'b00000000000000000000000001000000;
	dif.dmemstore = 32'hDEADBEEF;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd1234;

	@(posedge dif.dhit); // dhit??
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;

	///////////////////////
	//Test 2:
	//Load into set 0 (way 2 should be populated now)
	///////////////////////
	testcase++;
	dif.dmemaddr = 32'b00000000000000000000000010000000;
	dif.dmemstore = 32'hDEADBEEF;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd4321;

	@(posedge dif.dhit); // dhit??
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;

	///////////////////////
	//Test 3:
	//Load into set 1 
	///////////////////////
	testcase++;
	dif.dmemaddr = 32'b00000000000000000000000001001000;
	dif.dmemstore = 32'hDEADBEEF;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd4321;

	@(posedge dif.dhit); // dhit??
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;


	///////////////////////
	//Test 4:
	// Write from datapath to cache to set 0, should set dirty and LRU
	///////////////////////
	testcase++;
	dif.dmemaddr = 32'b00000000000000000000001000000100;
	dif.dmemstore = 32'hCADF00D;
	dif.dmemREN = 0;
	dif.dmemWEN = 1;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd4321;

	@(posedge dif.dhit);
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;

	///////////////////////
	//Test 5:
	// Write from datapath to cache to set 0, should replace based on LRU & set dirty
	///////////////////////
	testcase++;
	dif.dmemaddr = 32'b00000000000000000000010000000000;
	dif.dmemstore = 32'hCADF00D;
	dif.dmemREN = 0;
	dif.dmemWEN = 1;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd4321;

	@(posedge dif.dhit);
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;

	///////////////////////
	//Test 6:
	// Try reading from the cache, should get a hit & should not write to cache
	///////////////////////
	testcase++;
	dif.dmemaddr = 32'b00000000000000000000010000000000;
	dif.dmemstore = 32'hECE43700;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'hDEADBEEF;

	@(posedge dif.dhit);
	@(negedge CLK);
	cif.dwait = 1;
	@(posedge CLK);
	cif.dwait = 0;
	

	///////////////////////
	//Test 7:
	// Halt -> should flush dirties 
	///////////////////////
	testcase++;
	dif.halt = 1;

	$finish();
end


task memresponse(
	input word_t data
	);
	begin
		//Give data values, toggle dwait to simulate memory response
		
		@(negedge CLK);
		if (cif.dREN | cif.dWEN) begin
			cif.dwait = 1;
			cif.dload = data;
		end else begin
			cif.dload = 32'hECE43700;
		end
		@(posedge CLK);
		cif.dwait = 0;
	end
endtask 

task wait1 ();
    begin
	@(posedge CLK);
	nRST = 1;
    end
endtask

endmodule // dcache_tb
