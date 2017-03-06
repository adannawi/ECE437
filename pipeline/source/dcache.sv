
`include "cpu_types_pkg.vh"
`include "caches_if.vh"

module dcache (
	caches_if.dcache icif
	);

  // dcache ports
  //modport dcache (
  //  input   halt, dmemREN, dmemWEN,
  //          datomic, dmemstore, dmemaddr,
  //  output  dhit, dmemload, flushed
  //);

endmodule