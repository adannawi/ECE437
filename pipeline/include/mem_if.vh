
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
  logic writeRegIN, writeRegOUT;
  logic MemtoRegIN, MemtoRegOUT;
  word_t PCIncIN, PCIncOUT;
  //logic dWEN;
  //logic dREN;
  logic [4:0] rwIN, rwOUT;
  opcode_t opcodeOUT, opcodeIN;
  logic [1:0] RegWDSelIN, RegWDSelOUT;
  logic enable, flush;
  word_t resultIN, resultOUT;
  //word_t busB;
  word_t dmemloadOUT, dmemloadIN;
  //logic [25:0] addr;

  modport my  (
    input PCIncIN, writeRegIN, MemtoRegIN, RegWDSelIN, opcodeIN,
	  resultIN, rwIN, dmemloadIN, enable, flush,
    output PCIncOUT, writeRegOUT, MemtoRegOUT, RegWDSelOUT, opcodeOUT,
    dmemloadOUT, resultOUT, rwOUT
  );

  modport tb  (
    input PCIncOUT, writeRegOUT, MemtoRegOUT, RegWDSelOUT, opcodeOUT, dmemloadOUT, resultOUT, rwOUT,
    output PCIncIN, writeRegIN, MemtoRegIN, RegWDSelIN, opcodeIN, resultIN, rwIN, dmemloadIN, enable, flush
  );

endinterface

`endif
