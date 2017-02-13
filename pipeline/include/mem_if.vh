
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
  logic dWEN;
  logic dREN;
  logic [4:0] rwIN, rwOUT;
  opcode_t opcodeOUT, opcodeIN;
  logic [1:0] RWDSelIN, RWDSelOUT;
  logic enable, flush;

  word_t resultIN, resultOUT;
  word_t busB;
  word_t dmemloadOUT, dmemloadIN, dmemstore;
  logic [25:0] addr;

  modport my  (
    input PCIncIN, writeRegIN, MemtoRegIN, RWDSelIN, opcodeIN,
	  resultIN, rwIN, dmemloadIN,
    output PCIncOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT, opcodeOUT,
    dmemloadOUT, resultOUT, rwOUT
  );

  //modport tb  (
  //  input PCIncOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT, opcodeOUT, dmemload, resultOUT, dmemstore,
  //  output PCIncIN, writeRegIN, MemtoRegIN, RWDSelIN, dWEN, dREN, opcodeIN,
//	  resultIN, busB, rwIN
  //);

endinterface

`endif
