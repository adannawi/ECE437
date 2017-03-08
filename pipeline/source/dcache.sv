`include "caches_if.vh"
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"

module dcache (
	datapath_cache_if dcif,
	caches_if.dcache cif
	);

	typedef struct packed {
		logic valid;
		logic dirty;
		logic [ITAG_W-1:0] tag;
		word_t block1;
		word_t block2;
	 dway;

	typedef struct packed {
		dway way1
		dway way2
	} dset;


  // dcache ports
  //modport dcache (
  //  input   halt, dmemREN, dmemWEN,
  //          datomic, dmemstore, dmemaddr,
  //  output  dhit, dmemload, flushed
  //);

endmodule