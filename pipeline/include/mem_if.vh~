
/* Noah Petersen

  Interface for Pipeline Data memory

*/

`ifndef MEM_IF_VH
`define MEM_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

interface mem_if;

  //Import types
  //previous import
  //Signal declarations
  logic writeReg_in, writeReg_out;
  logic MemtoReg_in, MemtoReg_out;
  word_t PCInc_in, PCInc_out;
  logic dWEN;
  logic dREN;
  logic [4:0] rw_in, rw_out;
  opcode_t opcode_out, opcode_in;
  logic [1:0] RWDSel_in, RWDSel_out;


  word_t result_in, result_out;
  word_t busB;
  word_t dmemload, dmemstore;
  logic [25:0] addr;
 
  modport my  (
    input PCInc_in, writeReg_in, MemtoReg_in, RWDSel_in, dWEN, dREN, opcode_in,
	  result_in, busB, rw_in,
    output PCInc_out, writeReg_out, MemtoReg_out, RWDSel_out, opcode_out, dmemload, result_out, dmemstore
  );

  modport tb  (
    input PCInc_out, writeReg_out, MemtoReg_out, RWDSel_out, opcode_out, dmemload, result_out, dmemstore
    output PCInc_in, writeReg_in, MemtoReg_in, RWDSel_in, dWEN, dREN, opcode_in,
	  result_in, busB, rw_in
  );

endinterface

`endif
