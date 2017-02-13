
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
  logic writeRegIN, writeRegOUT;
  logic MemtoRegIN, MemtoRegOUT;
  logic dWENIN, dWENOUT;
  logic dRENIN, dRENOUT;
  logic branch;
  opcode_t opcodeOUT, opcodeIN;
  word_t instr
  aluop_t aluop;
  word_t PCIncIN, PCIncOUT;
  logic [1:0] RWDSelIN, RWDSelOUT;
  logic flush, enable;
  logic [1:0] PCSrc, RegDst, ALUSrc;
  logic [3:0] rd, rt, rwOUT, rwIN;
  //logic [25:0] addr;
  aluop_t aluop;
  opcode_t opcodeOUT, opcodeIN;
  word_t Ext_dat;
  word_t result;
  word_t instrIN, instrOUT;
  word_t busAIN, busAOUT;
  word_t busBIN, busBOUT;
  logic [25:0] addr;

  modport ex  (
    input PCIncIN, writeRegIN, MemtoRegIN, RWDSelIN, dWENIN, dRENIN, PCSrc, instr,
           opcodeIN, ALUSrc, RegDst, aluop, busAIN, busBIN, rd, rt, Ext_Dat,
    output PCIncOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT, dWENOUT, dRENOUT, opcodeOUT,
	   result, addr, busBOUT, busAOUT, branch, PCSrc
  );

  modport tb  (
    input PCIncOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT, dWENOUT, dRENOUT, opcodeOUT,
	   result, addr, busBOUT, busAOUT, branch, PCSrc
    output PCIncIN, writeRegIN, MemtoRegIN, RWDSelIN, dWENIN, dRENIN, PCSrc, instr,
           opcodeIN, ALUSrc, RegDst, aluop, busAIN, busBIN, rd, rt, Ext_Dat,

  );

endinterface

`endif
