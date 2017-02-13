/*
    Noah Petersen

    Controller.sv

    Sets control signals for the single cycle processor datapath based on the
    instruction provided, along with other feedback signals (just zero for now).
*/
`include "cpu_types_pkg.vh"
`include "controller_if.vh"

import cpu_types_pkg::*;

module controller (
  controller_if.ct ctif
);

//Signal Declarations
  opcode_t opcode;
  funct_t funct;

  // I/O Connections to internal signal names (if relevant)
  assign opcode = opcode_t'(ctif.instruction[31:26]);
  assign funct = funct_t'(ctif.instruction[5:0]);



  always_comb begin
    if(opcode == HALT) begin
      ctif.halt = 1;
    end else begin
      ctif.halt = 0;
    end
  end

/*
  assign rs = ctif.instruction[25:21];
sim:/system_tb/DUT/CPU/DP/ctif/instruction
  assign rt = ctif.instruction[20:16];
  assign rd = ctif.instruction[15:11];
  assign shamf = ctif.instruction[10:6];
  assign funct = ctif.instruction[5:0];
  assign imm16 = ctif.instruction[15:0];
  assign addr = ctif.instruction[25:0];
  */
  //assign for c<>tif.readreq&writereq

  //Controller -> Need more detailed setup for load/store  (RAM access) options
  always_comb begin
    ctif.ALUSrc = 2'b00; //SW Set
    ctif.MemtoReg = 0;  //Default of 0 is fine
    ctif.dreadreq = 0;  //Fine
    ctif.dwritereq = 0; //SW set
    ctif.RegDst = 0;    //DC
    ctif.PCSrc = 0;   //Default of +4 is desired
    ctif.ExtOp = 0;   //Sign extention desired, set by SW
    ctif.aluop = ALU_SLL; //ALU Add is setT/CPU/DP/cntrl File: source/con
    ctif.RegWDsel = 1'b0;;  //DC, not writing
    ctif.writeReg = 0;      //No write, default fine
    casez (opcode)
      RTYPE:
      //Subcase for the various R-type operations
      casez (funct)
        SLL:
        begin
          ctif.ALUSrc = 2'b10;
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SLL;
          ctif.RegWDsel = 1'b0;
          ctif.writeReg = 1;
        end
        SRL:
        begin
          ctif.ALUSrc = 2'b10;
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SRL;
          ctif.RegWDsel = 1'b0;
          ctif.writeReg = 1;
        end
        JR:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b10;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SLL; //Shouldn't matter, output is ignored
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 0;
        end
        ADD:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_ADD;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        ADDU:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_ADD;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        SUB:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SUB;
          ctif.RegWDsel = 1'b0;
          ctif.writeReg = 1;
        end
        SUBU:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SUB;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        AND:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_AND;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        OR:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_OR;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        XOR:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_XOR;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        NOR:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_NOR;
          ctif.RegWDsel = 1'b0;;
          ctif.writeReg = 1;
        end
        SLT:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SLT;
          ctif.RegWDsel = 1'b0;
          ctif.writeReg = 1;
        end
        SLTU:
        begin
          ctif.RegDst = 2'b01;
          ctif.PCSrc = 2'b00;
          ctif.ExtOp = 0;
          ctif.aluop = ALU_SLTU;
          ctif.RegWDsel = 2'b01;
          ctif.writeReg = 1;
        end
      endcase
      J:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b11;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_SLL;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 0;
      end
      JAL:
      begin
        ctif.RegDst = 2'b10;
        ctif.PCSrc = 2'b11;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_SLL;
        ctif.RegWDsel = 1'b1;
        ctif.writeReg = 1;
      end
      BEQ:
      begin
        ctif.PCSrc = 2'b01;
        ctif.RegDst = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_SUB;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 0;
        ctif.ALUSrc = 2'b00;
      end
      BNE:
      begin
        ctif.PCSrc = 2'b01;
        ctif.RegDst = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_SUB;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 0;
        ctif.ALUSrc = 2'b00;
      end
      ADDI:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 1;
        ctif.aluop = ALU_ADD;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;//Think
      end
      ADDIU:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 1;
        ctif.aluop = ALU_ADD;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;//ThinkT/CPU/DP/cntrl File: source/con
      end
      SLTI:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 1;
        ctif.aluop = ALU_SLT;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      SLTIU:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 1;
        ctif.aluop = ALU_SLTU;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      ANDI:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_AND;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      ORI:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_OR;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      XORI:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_XOR;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      LUI:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_SLL; //Default
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      LW:
      begin
        ctif.dreadreq = 1;
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 1;
        ctif.aluop = ALU_ADD;
        ctif.RegWDsel = 1'b0;
        ctif.MemtoReg = 1;
        ctif.writeReg = 1;
        ctif.ALUSrc = 2'b01;
      end
      SW:
      begin
        ctif.dwritereq = 1;
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 1;
        ctif.aluop = ALU_ADD;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 0;
        ctif.ALUSrc = 2'b01;
      end
      HALT:
      begin
        ctif.RegDst = 2'b00;
        ctif.PCSrc = 2'b00;
        ctif.ExtOp = 0;
        ctif.aluop = ALU_SLL;
        ctif.RegWDsel = 1'b0;
        ctif.writeReg = 0;
      end
    endcase
  end
endmodule
