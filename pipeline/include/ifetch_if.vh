
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
  //logic PCEn, branch;
  //logic [1:0] PCSrc;
  //logic [25:0] addr;
  logic flush, enable;
  word_t InstructionIN, InstructionOUT;
  word_t PCIncIN, PCIncOUT;
  opcode_t opcodeIN, opcodeOUT;


  modport fi (
    input PCIncIN, InstructionIN, opcodeIN, flush, enable,
    output PCIncOUT, InstructionOUT, opcodeOUT
  );

  modport tb  (
    input PCIncOUT, InstructionOUT, opcodeOUT,
    output PCIncIN, InstructionIN, opcodeIN, flush, enable
  );

endinterface

`endif
