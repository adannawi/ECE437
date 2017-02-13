
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
  //logic branch;
  //opcode_t opcodeOUT, opcodeIN;
  //word_t instr;
  //aluop_t aluop;

  logic [1:0] RWDSelIN, RWDSelOUT;
  logic flush, enable;
  logic [1:0] PCSrc, RegDst, ALUSrc;
  //logic [4:0] rd, rt, 
  logic [4:0] rwOUT, rwIN; //Why are rd/rt here?
  //logic [25:0] addr;
  opcode_t opcodeOUT, opcodeIN;
  //word_t Ext_dat;
  word_t resultIN, resultOUT;
  //word_t instrIN, instrOUT;
  //word_t busAIN, busAOUT;
  word_t busBIN, busBOUT;
  //logic [25:0] addr; -> this will get passed directly from insturction

  modport ex  (
    input PCIncIN, writeRegIN, MemtoRegIN, RWDSelIN, dWENIN, dRENIN, opcodeIN, busBIN, resultIN, rwIN,
    output PCIncOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT, dWENOUT, dRENOUT, opcodeOUT,
	   busBOUT, resultOUT, rwOUT
  );

  modport tb  (
    input PCIncOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT, dWENOUT, dRENOUT, opcodeOUT,
	   busBOUT, resultOUT, rwOUT,
    output PCIncIN, writeRegIN, MemtoRegIN, RWDSelIN, dWENIN, dRENIN,
           opcodeIN, busBIN, resultIN, rwIN

  );

endinterface

`endif
