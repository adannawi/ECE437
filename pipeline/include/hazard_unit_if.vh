/* Ziad Dannawi
  Interface for the Hazard Unit
*/

`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface hazard_unit_if;

  import cpu_types_pkg::*;

  //removed signals: jump

  // FORWARDING UNIT SIGNALS //
  logic [4:0] rs, rt;
  logic [4:0] execDest, memDest, wbDest;
  logic A_fw, B_fw;
  logic [31:0] A_fwdata, B_fwdata;

  // HAZARD UNIT SIGNALS //
  logic branch,  PCStall;
  logic fetch_stall, fetch_flush;
  logic decode_stall, decode_flush;
  logic execute_stall, execute_flush;
  logic memory_stall, memory_flush;
  logic MemRead_Ex, MemRead_Mem;
  logic ihit, dhit;
  logic writeReg_mem, writeReg_exec;
  opcode_t opcode;

  modport hu (
    input rs, rt, opcode, execDest, memDest, MemRead_Ex, MemRead_Mem, ihit,
    dhit, branch, writeReg_mem, writeReg_exec,
    output PCStall, fetch_stall, fetch_flush, decode_stall, decode_flush,
    execute_stall, execute_flush, memory_stall, memory_flush
  );

  modport tb (
    input PCStall, fetch_stall, fetch_flush, decode_stall, decode_flush,
    execute_stall, execute_flush, memory_stall, memory_flush,
    output rs, rt, opcode, execDest, memDest, MemRead_Ex, MemRead_Mem, ihit,
    dhit, branch
  );

endinterface
`endif
