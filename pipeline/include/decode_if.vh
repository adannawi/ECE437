
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
  logic writeRegIN, writeRegOUT, MemtoRegOUT, MemtoRegIN, dWENOUT, dWENIN,
  dRENOUT, dRENIN;
  logic [1:0] PCSrcOUT, PRSrcIN, RWDSelOUT, RWDSelIN, RegDstOUT, RegDstIN,
  ALUSrcOut, ALUSrcIN;
  logic [3:0] RdIN, RdOUT, RtIN, RtOUT, Rw;
  //logic [25:0] addr;
  aluop_t aluopIN, aluopOUT;
  opcode_t opcode_out, opcode_in;
  word_t ext_datIN, ext_datOUT, busAIN, busAOUT, busBIN, busBOUT, dataout;
  word_t InstructionIN, InstructionOUT, PCIncIN, PCIncOUT;
  logic flush, enable;

  modport de  (
    input PCIncIN, InstructionIN, writeRegIN, MemtoRegIN, RWDSelIN,
    dWENIN, dRENIN, PCSrcIN, RegDstIN, ALUSrcIN, aluopIN, ext_datIN, busAIN,
    busBIN, RtIN, RdIN,
    output PCIncOUT, InstructionOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT,
    dWENOUT, dRENOUT, PCSrcOUT, RegDstOUT, ALUSrcOUT, aluopOUT, ext_datOUT,
    busAOUT, busBOUT, RtOUT, RdOUT
    );

  modport tb  (
    input writeREg, MemtoReg, RWDSel, dWEN, dREN, PCSrc, InstructionOUT,
           opcode_out, ALUSrc, RegDst, aluop, busA, busB, rd, rt,
    output PCInc, InstructionIN, opcode_in, writeReg, dataout, rw
  );

endinterface

`endif
