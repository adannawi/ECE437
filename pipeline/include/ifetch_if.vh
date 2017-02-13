
/* Noah Petersen

  Interface for fetch section of pipeline

*/

`ifndef IFETCH_IF_VH
`define IFETCH_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

interface ifetch_if;

  //Import types
  //previous import
  //Signal declarations
  logic PCEn, branch;
  logic [1:0] PCSrc;
  logic [25:0] addr;

  word_t instruction, PCInc;
  opcode_t opcode;
  modport fi  (
    input addr, branch, PCSrc, PCen,
    output PCInc, instruction, opcode
  );

  modport tb  (
    input PCInc, instruction, opcode,
    output addr, branch, Ext_dat, PCSrc, PCen
  );

endinterface

`endif
