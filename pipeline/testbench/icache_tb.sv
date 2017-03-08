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

	// Load value into address
	@(negedge CLK);
	dif.imemaddr = 32'hECE43700;
	@(posedge CLK);
	@(negedge CLK);
	dif.imemREN = 1;
	cif.iwait = 0;
	cif.iload = 32'hFEEDBEEF;
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


	// Test #1: See if data matches & ihit
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

	// Test #2: See if data matches & ihit
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

end
endprogram