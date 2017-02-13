/* Noah Petersen

  Interface for Pipeline Data memory

*/

`ifndef WRITE_BACK_IF_VH
`define WRITE_BACK_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

interface write_back_if;

  //Import types
  //previous import
  //Signal declarations
  logic writeReg_in, writeReg_out;
  logic MemtoReg;
  word_t PCInc;
  word_t dmemload;
  logic [4:0] rw_in, rw_out;
  opcode_t opcode; //Just here for visibility
  logic [1:0] RWDSel;
  word_t result;
  word_t dataout;

 
  modport wb  (
    input PCInc, writeReg_in, MemtoReg, RWDSel, opcode, dmemload, result, rw_in,
    output dataout, rw_out, writeReg_out
  );

  modport tb  (
    input dataout, rw_out, writeReg_out,
    output PCInc, writeReg_in, MemtoReg, RWDSel, opcode, dmemload, result, rw_in
  );

endinterface

`endif
