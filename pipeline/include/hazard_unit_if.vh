/* Ziad Dannawi
  Interface for the Hazard Unit and Forwarding Unit
*/

`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface hazard_unit_if;

  import cpu_types_pkg::*;

  //removed signals: jump

  /////////////////////////////
  // FORWARDING UNIT SIGNALS //
  /////////////////////////////

  logic [4:0] rs_f, rt_f;
  logic [4:0] execDest, memDest, wbDest;
  logic [1:0] A_fw, B_fw;
  logic [1:0] ALUSrc;

  /////////////////////////
  // HAZARD UNIT SIGNALS //
  /////////////////////////

  logic [4:0] rs, rt;
  logic branch,  PCStall;
  logic fetch_stall, fetch_flush;
  logic decode_stall, decode_flush;
  logic execute_stall, execute_flush;
  logic memory_stall, memory_flush;
  logic MemRead_Ex, MemRead_Mem;
  logic ihit, dhit;
  logic writeReg_mem, writeReg_exec, writeReg_wb;
  opcode_t opcode;

  modport hu (
    input rs, rt, rs_f, rt_f, opcode, execDest, memDest, wbDest, MemRead_Ex, MemRead_Mem, ihit,
    dhit, branch, writeReg_mem, writeReg_exec, ALUSrc, writeReg_wb,
    output PCStall, fetch_stall, fetch_flush, decode_stall, decode_flush,
    execute_stall, execute_flush, memory_stall, memory_flush, A_fw, B_fw
  );

  modport tb (
    input PCStall, fetch_stall, fetch_flush, decode_stall, decode_flush,
    execute_stall, execute_flush, memory_stall, memory_flush,
    output rs, rt, opcode, execDest, memDest, MemRead_Ex, MemRead_Mem, ihit,
    dhit, branch
  );

endinterface
`endif
