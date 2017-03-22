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

initial begin
	@(negedge CLK);
	nRST = 0;
	@(posedge CLK);
	@(negedge CLK);
	nRST = 1;
	@(posedge CLK);

	//Load into the cache
	dif.dmemaddr = 4*1;
	dif.dmemstore = 32'hDEADBEEF;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd1234;

	@(posedge CLK); // dhit??

	dif.dmemaddr = 4*2;
	dif.dmemstore = 32'hDEADBEEF;
	dif.dmemREN = 1;
	dif.dmemWEN = 0;
	dif.halt = 0;
	cif.dwait = 0;
	cif.dload = 32'habcd4321;

	@(posedge CLK);

	// Case: Check for hit
	dif.dmemaddr = 4*1;
	dif.halt = 0;
	cif.dwait = 0;
	#3;
	if (dif.dhit == 1) begin
		$display("Hit, nice!");
	end else begin
		$display("Miss, nooo!");
	end
	if (dif.dmemload == 32'habcd1234) begin
		$display("Data is good");
	end else begin
		$display("Data is bad");
	end

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
