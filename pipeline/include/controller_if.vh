/* Noah Petersen

  Interface for Controller (for single cycle)

*/

`ifndef CONTROLLER_IF_VH
`define CONTROLLER_IF_VH

// Include CPU types to make things easier
`include "cpu_types_pkg.vh"
  //Import types

import cpu_types_pkg::*;

interface controller_if;


//Note datomic is removed here
  logic halt, dreadreq, dwritereq, writeReg, MemtoReg, ExtOp;
  logic [1:0] RegDst;
  logic RegWDsel;
  logic [1:0] PCSrc;
  logic [1:0] ALUSrc;
  aluop_t aluop;
  word_t instruction;


  //Signal declarations
  modport ct  (
    input  instruction,
    output halt, dreadreq, dwritereq, RegDst, PCSrc, ExtOp, aluop, RegWDsel,
           MemtoReg, writeReg, ALUSrc
  );

  modport tb  (
    input halt, dreadreq, dwritereq, RegDst, PCSrc, ExtOp, aluop, RegWDsel,
           MemtoReg, writeReg, ALUSrc,
    output  instruction
  );

endinterface

`endif
