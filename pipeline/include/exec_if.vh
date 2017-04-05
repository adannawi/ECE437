
/* Noah Petersen

  Interface for Pipeline Execute

*/

`ifndef EXEC_IF_VH
`define EXEC_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

interface exec_if;

  //Import types
  //previous import
  //Signal declarations
  word_t PCIncIN, PCIncOUT;
  logic writeRegIN, writeRegOUT;
  logic MemtoRegIN, MemtoRegOUT;
  logic dWENIN, dWENOUT;
  logic dRENIN, dRENOUT;
  word_t InstructionIN, InstructionOUT;



  logic RegWDSelIN, RegWDSelOUT;
  logic flush, enable;


  logic [4:0] rwOUT, rwIN;

  opcode_t opcodeOUT, opcodeIN;
  word_t resultIN, resultOUT;
  word_t busBIN, busBOUT;

  modport ex  (
    input PCIncIN, writeRegIN, MemtoRegIN, RegWDSelIN, dWENIN, dRENIN, opcodeIN,
    busBIN, resultIN, rwIN, flush, enable, InstructionIN,
    output PCIncOUT, writeRegOUT, MemtoRegOUT, RegWDSelOUT, dWENOUT, dRENOUT, opcodeOUT,
	   busBOUT, resultOUT, rwOUT, InstructionOUT
  );

  modport tb  (
    input PCIncOUT, writeRegOUT, MemtoRegOUT, RegWDSelOUT, dWENOUT, dRENOUT, opcodeOUT,
	   busBOUT, resultOUT, rwOUT, InstructionOUT,
    output PCIncIN, writeRegIN, MemtoRegIN, RegWDSelIN, dWENIN, dRENIN,
           opcodeIN, busBIN, resultIN, rwIN, InstructionIN

  );

endinterface

`endif
