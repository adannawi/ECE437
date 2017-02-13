/*
    Noah Petersen

    Controller Testbench

    Testbench for single cycle controller.
*/
//`timescale 1 ns / 1 ns
`include "cpu_types_pkg.vh"
`include "controller_if.vh"

`timescale 1 ns / 1 ns

import cpu_types_pkg::*;

module controller_tb;

  //Clock Declaration
  parameter PERIOD = 20;
  logic CLK = 1;

  always #(PERIOD/2) CLK++;

  //For all
  //logic [5:0] opcode;
  opcode_t opcode;
  //For R/I
  logic [4:0] rs, rt;

  //For R
  logic [4:0] rd, shamt;
  //logic [5:0] funct;
  funct_t funct;

  //For I/format
  logic [15:0] imm;

  //For J-format
  logic [25:0] addr;

  //Test Interface
  controller_if ctif ();
  logic nRST;

  //DUT
`ifndef MAPPED
  controller DUT(
      .ctif(ctif)
      );
`else
  controller DUT(
      .\ctif.instruction (ctif.instruction), //ref
      .\ctif.halt (ctif.halt), //ref
      .\ctif.dreadreq (ctif.dreadreq), //ref
      .\ctif.dwritereq (ctif.dwritereq), //ref
      .\ctif.RegDst (ctif.RegDst),  //ref
      .\ctif.PCSrc (ctif.PCSrc),  //ref
      .\ctif.ExtOp (ctif.ExtOp),  //ref
      .\ctif.aluop (ctif.aluop[3:0]),  //ref, also say is incompatible
      .\ctif.RegWDsel (ctif.RegWDsel), //ref
      .\ctif.MemtoReg (ctif.MemtoReg),  //ref
      .\ctif.writeReg (ctif.writeReg), //ref
      .\ctif.ALUSrc (ctif.ALUSrc)  //ref
    );
/*  controller DUT(
      .ctif(ctif)
      );*/
`endif
  initial begin
  ctif.instruction = 0;
  wait1();

  //R-Type Test Caise
  //Set: opcode, rs, rt, rd, shamt, funct
  //Test Case 1: ADD (basic rd = rs + rt)
  opcode = RTYPE;
  rs = 5'b00010;
  rt = 5'b00011;
  rd = 5'b00100;
  shamt = '0;
  funct = ADD;
  sendr();

  //Test Case 2: JR (special)
  opcode = RTYPE;
  rs = 5'b00100;
  rt = 5'b00000;
  rd = 5'b00000;
  shamt = '0;
  funct = JR;
  sendr();

  //Test Case 3: SLL (uses SHAMT)
  opcode = RTYPE;
  rs = 5'b00010;
  rt = 5'b00000;
  rd = 5'b00000;
  shamt = 5'b00010;
  funct = SLL;
  sendr();

  //I Type Instructions
  //Set: opcode, rs, rt, imm (imm doesn't matter, data)
  //ADDI (uses SignExtImm)
  opcode = ADDI;
  rs = 5'b00001;
  rt = 5'b00010;
  imm = 16'hF000;
  sendi();
  //ANDI (uses ZeroExtImm)
  opcode = ANDI;
  rs = 5'b00001;
  rt = 5'b00010;
  imm = 16'hFA50;
  sendi();

  //BEQ (special branch settings)
  opcode = BEQ;
  rs = 5'b00001;
  rt = 5'b00010;
  imm = 16'h0000;
  sendi();

  //LW (Load word)
  opcode = LW;
  rs = 5'b00001;
  rt = 5'b00010;
  imm = 16'h0010;
  sendi();

  //SW (Store word)
  opcode = SW;
  rs = 5'b00001;
  rt = 5'b00010;
  imm = 16'h0010;
  sendi();

  //LUI (Unusual exception)
  opcode = LUI;
  rs = 5'b00000;
  rt = 5'b00100;
  imm = 16'hFFFF;
  sendi();

  //Jump Instructions
  //Set: opcode, addr (addr doesn't matter, is data)
  //JAL - basic settings for Jump, PLUS Linking
  opcode = JAL;
  addr = 25'b0000000000011111000000;
  sendj();

  //HALT
  opcode = HALT;
  sendj();
  $finish;
  end

task sendi();
  begin
    //#(10);
    ctif.instruction = word_t'({opcode,rs,rt,imm});
    //#(10);
    wait1();
  end
  endtask

  task sendj();
  begin
    //#(10);
    ctif.instruction = word_t'({opcode,addr});
    //#(10);
    wait1();
  end
  endtask

  task sendr();
  begin
   // #(10);
    ctif.instruction = word_t'({opcode,rs,rt,rd,shamt,funct});
    //#(10);
    wait1();
  end
  endtask

  task wait1();
  begin
    #(10);
    ctif.instruction = ctif.instruction;
  end
  endtask


endmodule
