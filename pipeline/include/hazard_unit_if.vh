/* Ziad Dannawi
  Interface for the Hazard Unit
*/

`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH

`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

interface hazard_unit_if;
  logic rs_0, rs_1, branch, jump, execDest, memDest, PCEn;
  logic fetch_enable, fetch_flush;
  logic decode_enable, decode_flush;
  logic execute_enable, execute_flush;
  logic memory_enable, memory_flush;

  modport hu (
    input rs_0, rs_1, branch, jump, execDest, memDest,
    output PCEn, fetch_enable, fetch_flush, decode_enable, decode_flush,
    execute_enable, execute_flush, memory_enable, memory_flush
  );
