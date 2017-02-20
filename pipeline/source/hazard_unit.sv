/* Ziad Dannawi
  Hazard Unit code
*/


`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;
module hazard_unit (
  input CLK, nRST,
  hazard_unit_if.hu huif
);


always_comb
begin
  huif.fetch_stall = 0;
  huif.fetch_flush = 0;
  huif.decode_stall = 0;
  huif.decode_flush = 0;
  huif.memory_stall = 0;
  huif.memory_flush = 0;
  huif.execute_stall = 0;
  huif.execute_flush = 0;
  huif.PCStall = 0;
  huif.A_fw = 0;
  huif.B_fw = 0;


  // General solution for all stalling
  // While stalled, inject nop in place of stalled instr in next stage (as many
  // nops as stalls
  // Freeze later instructions behind as long as stalled
  // Continue earlier instructions ahead

  /////////////////
  //  FORWARDING //
  /////////////////
  // ALU Ports (A_fwd/B_fwd)
  // 00 - Default
  // 01 - Mem Data
  // 10 - WB Data
  //////////////////

  if ((huif.memDest == huif.rs_f) || (huif.memDest == huif.rt_f) && huif.writeReg_mem) begin
    if (huif.memDest != 0) begin
      huif.A_fw = 01;
      huif.B_fw = 01;
    end
  end

  if ((huif.wbDest == huif.rs_f) || (huif.wbDest == huif.rt_f) && huif.writeReg_wb) begin
    if (huif.wbDest != 0) begin
      huif.A_fw = 10;
      huif.B_fw = 10;
    end
  end

  // Check for i-type and set B to ignore forwarding
  if (huif.ALUSrc == 01) begin
    huif.A_fw = 00; 
    huif.B_fw = 00;
  end
  /////////////////
  // HAZARD UNIT //
  /////////////////

  // New case where ADD is in Decode but there's a LW in Execute.. Add NOP in Execute??


  //
  
  // Handle Ld-Use Hazard //
  if (huif.MemRead_Ex & ((huif.execDest == huif.rs) || (huif.execDest == huif.rt))) begin
		if (huif.execDest != 0) begin
	   	huif.PCStall = 1;
    	huif.fetch_stall = 1;
    	huif.decode_stall = 1;
    	huif.decode_flush = 1;
		end
  end

	if (huif.MemRead_Mem & ((huif.memDest == huif.rs) || (huif.memDest == huif.rt ))) begin
    if (huif.memDest != 0) begin
    	huif.PCStall = 1;
    	huif.fetch_stall = 1;
    	huif.decode_stall = 1;
    	huif.decode_flush = 1;
  	end
  end

  // Handle Control Hazard (Branches / Jumps) //
  if ((huif.opcode == BEQ || huif.opcode == BNE) && huif.branch) begin
    huif.fetch_flush = 1;
    huif.decode_flush = 1;
  end

  if (huif.opcode == JAL || huif.opcode == J || huif.opcode == JR) begin
    huif.fetch_flush = 1;
    huif.decode_flush = 1;
  end

  // Flush the execute flush on a dhit and move LW into WB stage //
  if (huif.dhit) begin
    huif.execute_flush = 1;
  end

  // Handle RAW Hazard //
  // Commented because this should now be handled in the forwarding unit
  /*
  if (huif.writeReg_exec && ((huif.execDest == huif.rs) || (huif.execDest == huif.rt))) begin
    if (huif.memDest != 0) begin
      huif.PCStall = 1;
      huif.fetch_stall = 1;
      huif.decode_flush = 1;
    end
  end

  if (huif.writeReg_mem && ((huif.memDest == huif.rs) || (huif.memDest == huif.rt))) begin
    if (huif.memDest != 0) begin
      huif.PCStall = 1;
      huif.fetch_stall = 1;
      huif.decode_flush = 1;
    end
  end
  */


end
endmodule
