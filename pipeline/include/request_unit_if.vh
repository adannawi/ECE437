
/* Noah Petersen

  Interface for single cycle request unit.

*/

`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

interface request_unit_if;

  //Import types
  //previous import
  //Signal declarations
  logic dreadreq, dwritereq, ireadreq, dhit, ihit, halt;
  logic dREN, dWEN, iREN;

  modport ru  (
    input dreadreq, dwritereq, ireadreq, dhit, ihit, halt,
    output dREN, dWEN, iREN
  );

  modport tb  (
    input dREN, dWEN, iREN,
    output dreadreq, dwritereq, ireadreq, dhit, ihit, halt
  );

endinterface

`endif
