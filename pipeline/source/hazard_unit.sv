/* Ziad Dannawi
  Hazard Unit code
*/


`include "hazard_unit_if.vh"
import cpu_types_pkg::*;

module hazard_unit
(
  input CLK, nRST,
  hazard_unit_if.hu huif
);
always_comb:
begin
  huif.fetch_stall = 0;
  huif.fetch_flush = 0;
  huif.decode_stall = 0;
  huif.decode_flush = 0;
  huif.execute_stall = 0;
  huif.execute_flash = 0;
  huif.memory_stall = 0;
  huif.memory_flush = 0;
  huif.PCStall = 0;

  // General solution for all stalling
  // While stalled, inject nop in place of stalled instr in next stage (as many
  // nops as stalls
  // Freeze later instructions behind as long as stalled
  // Continue earlier instructions ahead



  // Handle Ld-Use Hazard
  if (huif.memRead_Ex & ((execDest == rs) | (execDest == rt ))) |
    (huif.memRead_Mem & ((memDest == rs) | (memDset == rt )))   begin
    // check if execDest == 0 for load use??
    huif.PCStall = 1;
    huif.fetch_stall = 1;
    huif.decode_stall = 1;
  end

  // Handle RAW Hazard
  if ((execDest == rs) | (execDest == rt)) begin
    if (execDest != 0) begin
      huif.PCStall = 1;
      huif.fetch_stall = 1;
      huif.decode_stall = 1;
    end
  end

  // Handle Control Hazard (Branches / Jumps)
  if (opcode == "BEQ" || opcode == "BNE") begin
    huif.fetch_flush = 1;
  end
end

  // Flush the execute flush on a dhit and move LW into WB stage
  assign huif.execute_flush = huif.dhit;

endmodule
