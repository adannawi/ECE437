
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
  word_t PCIncIN, PCIncOUT;
  logic writeRegIN, writeRegOUT;
  logic MemtoRegOUT, MemtoRegIN;
  logic dWENOUT, dWENIN;
  logic dRENOUT, dRENIN;
  logic [1:0] PCSrcOUT, PCSrcIN;
  logic RWDSelOUT, RWDSelIN;
  logic [1:0] RegDstOUT, RegDstIN;
  logic [1:0] ALUSrcOUT, ALUSrcIN;
  logic [4:0] rdIN, rdOUT; 
  logic [4:0] rtIN, rtOUT;
  //logic [25:0] addr;
  aluop_t aluopIN, aluopOUT;
  opcode_t opcodeOUT, opcodeIN;
  word_t ext_datIN, ext_datOUT;
  word_t busAIN, busAOUT;
  word_t busBIN, busBOUT;
  word_t InstructionIN, InstructionOUT;
  logic flush;
  logic enable;

  modport de  (
    input PCIncIN, InstructionIN, writeRegIN, MemtoRegIN, RWDSelIN,
    dWENIN, dRENIN, PCSrcIN, RegDstIN, ALUSrcIN, aluopIN, ext_datIN, busAIN,
    busBIN, rtIN, rdIN, opcodeIN, flush, enable,
 
    output PCIncOUT, InstructionOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT,
    dWENOUT, dRENOUT, PCSrcOUT, RegDstOUT, ALUSrcOUT, aluopOUT, ext_datOUT,
    busAOUT, busBOUT, rtOUT, rdOUT, opcodeOUT
    );

  modport tb  (
    input PCIncOUT, InstructionOUT, writeRegOUT, MemtoRegOUT, RWDSelOUT,
    dWENOUT, dRENOUT, PCSrcOUT, RegDstOUT, ALUSrcOUT, aluopOUT, ext_datOUT,
    busAOUT, busBOUT, rtOUT, rdOUT, opcodeOUT,

    output PCIncIN, InstructionIN, writeRegIN, MemtoRegIN, RWDSelIN,
    dWENIN, dRENIN, PCSrcIN, RegDstIN, ALUSrcIN, aluopIN, ext_datIN, busAIN,
    busBIN, rtIN, rdIN, opcodeIN, flush, enable 
  );

endinterface

`endif
