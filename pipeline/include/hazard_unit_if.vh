/* Ziad Dannawi
  Interface for the Hazard Unit
*/

`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"

interface hazard_unit_if;

  import cpu_types_pkg::*;

  logic rs, rt, branch, jump, execDest, memDest, PCStall;
  logic fetch_stall, fetch_flush;
  logic decode_stall, decode_flush;
  logic execute_stall, execute_flush;
  logic memory_stall, memory_flush;
  logic MemRead_Ex, MemRead_Mem;
  logic ihit, dhit;
  opcode_t opcode;

  modport hu (
    input rs, rt, opcode, execDest, memDest, MemRead_Ex, MemRead_Mem, ihit,
    dhit, branch,
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
