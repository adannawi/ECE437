
/* Noah Petersen

  Interface for decode section of pipeline

*/

`ifndef DECODE_IF_VH
`define DECODE_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  import cpu_types_pkg::*;

interface decode_if;

  //Import types
  //previous import
  //Signal declarations
  logic writeReg, MemtoReg, dWEN, dREN;
  logic [1:0] PCSrc, RWDSel, RegDst, ALUSrc;
  logic [3:0] rd, rt, rw;
  //logic [25:0] addr;
  aluop_t aluop;
  opcode_t opcode_out, opcode_in;
  word_t Ext_dat, busA, busB, dataout;
  word_t instr_in, instr_out, PCInc_in, PCInc_out;

  modport de  (
    input PCInc_in, instr_in, opcode_in, writeReg, dataout, rw,
    output writeREg, MemtoReg, RWDSel, dWEN, dREN, PCSrc, instr_out,
           opcode_out, ALUSrc, RegDst, aluop, busA, busB, rd, rt, PCInc_out, Ext_dat
  );

  modport tb  (
    input writeREg, MemtoReg, RWDSel, dWEN, dREN, PCSrc, instr_out,
           opcode_out, ALUSrc, RegDst, aluop, busA, busB, rd, rt,
    output PCInc, instr_in, opcode_in, writeReg, dataout, rw
  );

endinterface

`endif
