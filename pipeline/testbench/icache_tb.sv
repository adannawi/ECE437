`include "caches_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

`timescale 1ns/1ns

module icache_tb;
	import cpu_types_pkg::*;

	parameter PERIOD = 10;
	logic CLK = 0;
	logic nRST = 0;
	always #(PERIOD/2) CLK++;

	caches_if cif ();
	datapath_cache_if dif ();
	test PROG (CLK, nRST, cif, dif);
	icache DUT (CLK, nRST, cif, dif);
endmodule // icache_tb

program test
	(
	input logic CLK,
	output logic nRST,
	caches_if cif,
	datapath_cache_if dif
	);
initial begin
	@(negedge CLK);
	nRST = 0;
	@(posedge CLK);
	nRST = 1;
/*
	// Load value into address & check if it detects initial miss
	@(negedge CLK);
	dif.imemaddr = 32'hECE43700;
	@(posedge CLK);
	@(negedge CLK);
	dif.imemREN = 1;
	cif.iwait = 0;
	cif.iload = 32'hFEEDBEEF;
	if (dif.ihit == 0) begin
		$display("Miss success!");
	end else begin
		$display("Hit detected, whaa?");
	end

	@(posedge CLK);
	// Wait a little, then load another value into another address
	@(negedge CLK);
	dif.imemREN = 1;
	cif.iwait = 1;
	cif.iload = 32'h01230123;
	dif.imemaddr = 32'h43212345;
	@(posedge CLK);
	@(posedge CLK);
	@(negedge CLK);
	cif.iwait = 0;


	// See if data matches & ihit
	@(posedge CLK);
	dif.imemaddr = 32'hECE43700;
	cif.iwait = 1;
	dif.imemREN = 1;
	@(negedge CLK);
	if (dif.imemload == 32'hFEEDBEEF) begin
		$display("Memory data matches!");
	end else begin
		$display("Nay!");
	end

	if (dif.ihit == 1) begin
		$display("Got a hit!");
	end else begin
		$display("No hit!");
	end

	// See if data matches & ihit
	@(posedge CLK);
	dif.imemaddr = 32'h43212345;
	@(negedge CLK);
	if (dif.imemload == 32'h01230123) begin
		$display("Memory data matches!");
	end else begin
		$display("Nay!");
	end

	if (dif.ihit == 1) begin
		$display("Got a hit!");
	end else begin
		$display("No hit!");
	end

	// Overwrite data of second address
	@(posedge CLK);
	cif.iload = 32'hDEADBEEF;
	cif.iwait = 0;
	@(negedge CLK);

	// Test #3: See if data was overwritten
	@(posedge CLK);
	cif.iwait = 1;
	@(negedge CLK);
	if (dif.imemload == 32'hDEADBEEF) begin
		$display("Memory data matches!");
	end else begin
		$display("Nay!");
	end
*/
	cif.iwait = 0;
	dif.imemREN = 1;
	cif.iload = 32'hFEEDBEEF;
	//Load all cache registers
	@(posedge CLK);
	dif.imemaddr = 4*0;
	@(posedge CLK);
	dif.imemaddr = 4*1;
	@(posedge CLK);
	dif.imemaddr = 4*2;
	@(posedge CLK);
	cif.iload = 32'hFEEBDEEF;
	dif.imemaddr = 4*3;
	@(posedge CLK);
	cif.iload = 32'hFEEDBEEF;
	dif.imemaddr = 4*4;
	@(posedge CLK);
	dif.imemaddr = 4*5;
	@(posedge CLK);
	dif.imemaddr = 4*6;
	@(posedge CLK);
	dif.imemaddr = 4*7;
	@(posedge CLK);
	dif.imemaddr = 4*8;
	@(posedge CLK);
	dif.imemaddr = 4*9;
	@(posedge CLK);
	dif.imemaddr = 4*10;
	@(posedge CLK);
	dif.imemaddr = 4*11;
	@(posedge CLK);
	dif.imemaddr = 4*12;
	@(posedge CLK);
	dif.imemaddr = 4*13;
	@(posedge CLK);
	dif.imemaddr = 4*14;
	@(posedge CLK);
	dif.imemaddr = 4*15;
	@(posedge CLK);
	dif.imemaddr = 4*3;
	#3;

	@(posedge CLK);

	///     Read data      ///
	dif.imemaddr = 4*0;
	#3;
	if (dif.imemload == 32'hFEEDBEEF) begin
		$display("Read idx 0 good");
	end else begin
		$display("Incorrect read idx 0");
	end

	@(posedge CLK);
	dif.imemaddr = 4*1;
	#3;
	if (dif.imemload == 32'hFEEDBEEF) begin
		$display("Read idx 1 good");
	end else begin
		$display("Incorrect read idx 1");
	end	

	@(posedge CLK);
	dif.imemaddr = 4*3;
	#3;
	if (dif.imemload == 32'hFEEBDEEF) begin
		$display("Read idx 1 good");
	end else begin
		$display("Incorrect read idx 1");
	end	

	// Case: Check for hit
	if (dif.ihit == 1) begin
		$display("Got a hit, good!");
	end else begin
		$display("No hit, bad!");
	end
	if (dif.imemload == 32'hFEEBDEEF) begin
		$display("Correct data read!");
	end else begin
		$display("Wrong data read! %d", dif.imemload);
	end

	@(posedge CLK);
	@(negedge CLK);
	// Case: check for miss
	dif.imemaddr = 4*17;
	cif.iload = 32'hDEADBEEF;
	#3;
	if (dif.ihit == 0) begin
		$display("Got a miss, good!");
	end else begin
		$display("hit, bad!");
	end
	@(posedge CLK);
	@(posedge CLK);
	// Case: check for conflict
	@(negedge CLK);
	dif.imemaddr = 4*18;
	cif.iload = 32'hECE43700;
	#3;
	if (dif.ihit == 0) begin
		$display("Got a miss, good!");
	end else begin
		$display("hit, bad!");
	end	
	@(posedge CLK);
	#1;
	if (dif.imemload == 32'hECE43700) begin
		$display("Data looks good");
	end else begin
		$display("Data is no good");
	end
	@(posedge CLK);
	@(posedge CLK);


end
endprogram