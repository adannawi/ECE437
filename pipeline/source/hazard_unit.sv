/* Ziad Dannawi
  Hazard Unit code
*/


`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module hazard_unit (
  input CLK, nRST,
  hazard_unit_if.hu huif
);
	//Internal signals for Debug:
	logic LUhaz;
	logic FWFLSHhaz;
	logic branch_haz;
	logic jump_haz;

//Forwarding unit
always_comb begin
  huif.A_fw = 0;
  huif.B_fw = 0;
  huif.SWsel = 2'b00;
  /////////////////
  //  FORWARDING //
  /////////////////
  // ALU Ports (A_fwd/B_fwd)
  // 00 - Default
  // 01 - Mem Data
  // 10 - WB Data
  //////////////////



	//ALU Input dependencies
	//Check Mem -> A FW
  if ((huif.memDest == huif.rs_f) && huif.writeReg_mem) begin
    if (huif.memDest != 5'b00000) begin
      huif.A_fw = 2'b01;
    end
  end


	//Check Mem -> B FW
	if ((huif.memDest == huif.rt_f) && huif.writeReg_mem) begin
    if ((huif.memDest != 5'b00000) && (huif.ALUSrc == 2'b00))  begin
      huif.B_fw = 2'b01;
    end
  end

	//Check WB -> A FW
  if ((huif.wbDest == huif.rs_f) && huif.writeReg_wb) begin
    if (huif.wbDest != 5'b00000)  begin
      huif.A_fw = 2'b10;
    end
  end

	//Check WB -> FW
	if ((huif.wbDest == huif.rt_f) && huif.writeReg_wb) begin
    if ((huif.wbDest != 5'b00000) && (huif.ALUSrc == 2'b00))begin
      huif.B_fw = 2'b10;
    end
  end

	//SW Dependencies
	//Special case based on our design where data which could (should?) be on bus B
	//Needs to be forwarded for storage
	if (huif.opcode == SW) begin //RS OR RT
		if ((huif.memDest == huif.rt_f) && huif.writeReg_mem) begin
			huif.SWsel = 2'b01;
		end else if ((huif.wbDest == huif.rt_f) && huif.writeReg_wb) begin
			huif.SWsel = 2'b10;
		end else begin
			huif.SWsel = 2'b00;
		end
	end
end
  // Check for i-type and set B to ignore forwarding

  /////////////////
  // HAZARD UNIT //
  /////////////////

  // New case where ADD is in Decode but there's a LW in Execute.. Add NOP in Execute??

  // General solution for all stalling
  // While stalled, inject nop in place of stalled instr in next stage (as many
  // nops as stalls
  // Freeze later instructions behind as long as stalled
  // Continue earlier instructions ahead

  //Hazard Logic (Flush/Stall)
always_comb begin
  huif.fetch_stall = 0;
  huif.fetch_flush = 0;
  huif.decode_stall = 0;
  huif.decode_flush = 0;
  huif.memory_stall = 0;
  huif.memory_flush = 0;
  huif.execute_stall = 0;
  huif.execute_flush = 0;
  huif.PCStall = 0;
  LUhaz = 0;
	FWFLSHhaz = 0;
	branch_haz = 0;
	jump_haz = 0;

  // Handle Ld-Use Hazard //
  if (huif.MemRead_Ex && huif.writeReg_exec && ((huif.execDest == huif.rs) || (huif.execDest == huif.rt))) begin
		if (huif.execDest != 5'b00000) begin
	   	huif.PCStall = 1;
    	huif.fetch_stall = 1;
    	//huif.decode_stall = 1;
    	huif.decode_flush = 1;
			//huif.execute_flush = 1;
			LUhaz = 1;
		end
  end

	/*
	if (huif.MemRead_Mem & ((huif.memDest == huif.rs) || (huif.memDest == huif.rt ))) begin
    if (huif.memDest != 0) begin
    	huif.PCStall = 1;
    	huif.fetch_stall = 1;
    	huif.decode_stall = 1;
    	huif.decode_flush = 1;
  	end
  end
	*/
	//Handle dependency where normally fw'd data gets flushed by either SW or LW (and is not directed at 0)
	if (huif.writeReg_mem && ((huif.memDest == huif.rs) || (huif.memDest == huif.rt)) && ((huif.opcode == SW) || (huif.opcode == LW))) begin
		if (huif.memDest != 5'b00000) begin
		  huif.PCStall = 1;
    	huif.fetch_stall = 1;
    	//huif.decode_stall = 1;
    	huif.decode_flush = 1;
			FWFLSHhaz = 1;
		end
	end

  // Handle Control Hazard (Branches / Jumps) //
  if ((huif.opcode == BEQ || huif.opcode == BNE) && huif.branch) begin
    huif.fetch_flush = 1;
    huif.decode_flush = 1;
		branch_haz = 1;
  end

  if ((huif.opcode == JAL) || (huif.opcode == J) || ((huif.rfunct == JR) && (huif.opcode == RTYPE))) begin
    huif.fetch_flush = 1;
    huif.decode_flush = 1;
		jump_haz = 1;
  end

  // Flush the execute reg on a dhit and move LW into WB stage //
  if (huif.dhit) begin
    huif.execute_flush = 1;
  end

end
endmodule
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

