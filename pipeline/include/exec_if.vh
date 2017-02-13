
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
  logic writeReg_in, writeReg_out;
  logic MemtoReg_in, MemtoReg_out;
  logic dWEN_in, dWEN_out;
  logic dREN_in, dREN_out;
  logic branch;
  opcode_t opcode_out, opcode_in;
  word_t instr
  aluop_t aluop;
  word_t PCInc_in, PCInc_out;
  logic [1:0] RWDSel_in, RWDSel_out;


  logic [1:0] PCSrc, RegDst, ALUSrc;
  logic [3:0] rd, rt, rw;
  //logic [25:0] addr;
  aluop_t aluop;
  opcode_t opcode_out, opcode_in;
  word_t Ext_dat; 
  word_t result;
  word_t instr_in, instr_out; 
  word_t busA_in, busA_out; 
  word_t busB_in, busB_out;
  logic [25:0] addr;
 
  modport ex  (
    input PCInc_in, writeReg_in, MemtoReg_in, RWDSel_in, dWEN_in, dREN_in, PCSrc, instr,
           opcode_in, ALUSrc, RegDst, aluop, busA_in, busB_in, rd, rt, Ext_Dat,
    output PCInc_out, writeReg_out, MemtoReg_out, RWDSel_out, dWEN_out, dREN_out, opcode_out,
	   result, addr, busB_out, busA_out, branch, PCSrc
  );

  modport tb  (
    input PCInc_out, writeReg_out, MemtoReg_out, RWDSel_out, dWEN_out, dREN_out, opcode_out,
	   result, addr, busB_out, busA_out, branch, PCSrc
    output PCInc_in, writeReg_in, MemtoReg_in, RWDSel_in, dWEN_in, dREN_in, PCSrc, instr,
           opcode_in, ALUSrc, RegDst, aluop, busA_in, busB_in, rd, rt, Ext_Dat,

  );

endinterface

`endif
