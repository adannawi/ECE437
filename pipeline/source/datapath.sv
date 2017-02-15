/*
  Noah Petersen, Ziad the OG

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor

  Contains these components from hierarchy diagram (as aluded above)
    pc
    register file
    control unit
    request unit
    alu

  Modified for Pipeline
*/

// data path interface
`include "datapath_cache_if.vh"
`include "mem_if.vh"
`include "decode_if.vh"
`include "ifetch_if.vh"
`include "exec_if.vh"
`include "hazard_unit_if.vh"

// alu op, mips op, and  type
`include "cpu_types_pkg.vh"

module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init -> what is this for? something to do with starting/initializing PC
  parameter PC_INIT = 0;

  // Internal Signal Declarations

  //  PC Related
  word_t PC; //Program Conuter
  word_t PCNxt; //Input to PC
  logic PCEn;

  //  Extender Signals
  word_t Ext_dat;

  //  Register Signals
  word_t ALU_Bin, ALU_Ain, B_data;
  word_t busA; //Output from register file Read Location 1
  word_t busB; //Output from register file Read Location 2


  logic [4:0] rs;
  logic [4:0] rt;
  logic [4:0] rd;
  logic [4:0] rw;
  logic [4:0] shamt;
  funct_t funct;
  logic [15:0] imm16;
  logic [26:0] addr;

  logic ihit, dhit; //halt;
  logic iREN;

  logic [1:0] PCSrc;
  word_t PCInc;
  word_t ALU_out, result;
  logic zero;
  logic neg;
  logic overflow;
  aluop_t aluop;

  word_t dataout;
  word_t RegWDat;
  word_t branchaddr;

  //    Register file interface
  register_file_if rfif1 ();

  //    Controller Interface
  controller_if ctif ();

  //    Request Unit Interface -> nix'd for pipeline
  //request_unit_if ruif ();

  //    Fetch Reg interface
  ifetch_if feif ();

  //    Decode Reg interface
  decode_if deif ();

  //    Execute Reg interface
  exec_if exif ();

  //    Mem Reg interface
  mem_if mmif ();

  //  Controller Signals
  opcode_t opcode;

	//  Hazard Unit Interface
  hazard_unit_if huif ();


  logic branch;

  //Request unit signals ->desired in order to manage timing of reads/writes
  logic ireadreq;
  //logic dreadreq;
  //logic dwritereq;

  //    Instruction type delarations & Related signals


///////////////////////////////////////////////////////////////////////

  //Pipeline Register Bank Instances
  mem_registers mem1 (CLK, nRST, mmif);
  decode_registers dc1 (CLK, nRST, deif);
  exec_registers exc1 (CLK, nRST, exif);
  fetch_registers fch1 (CLK, nRST, feif);

  ////////////////////////
  /*	FETCH STAGE	*/
  ////////////////////////

  //Modules

  /*	Fetch Register Connections */
  //inputs
  assign feif.InstructionIN = dpif.imemload;
  assign feif.PCIncIN = PCInc;
  assign feif.opcodeIN = opcode_t'(dpif.imemload[31:26]);
  //outputs (not to next pipe register)
  assign ctif.instruction = feif.InstructionOUT;

  //NEED TO INSERT DPIF SIGNALS FOR INTERFACING TO IMEM
	//Need to add in remainer of signals needed to interface to Instruction memor (via dpif)

  //PC Nxt Standard Update <- These may need to change
  assign PCInc = PC + 4;

  //See bottom of datapath for PCEn

  //PC -> How to wait for sw/lw? (need not just cycles but also ihit/dhit)
  always_ff @(posedge CLK, negedge nRST) begin
    if (nRST == 0) begin
      //What to do here? reset to 0 for now
      PC <= 0;
    end else if (PCEn == 1) begin
      PC <= PCNxt;
    end else begin
      PC <= PC;
    end
  end

//Next PC Selection MUX
  always_comb begin
    //Default
    PCNxt = PC;
    casez(PCSrc)
          //"Normal" Increment
      2'b00: PCNxt = PCInc;

          //Take data from sign extender, Lshift 2, add 4
          //    Why Lshift 2???
          //    Want
          //    Branch Condition?
      2'b01:  begin
                PCNxt = branchaddr;
              end
          //Branch logic handled in Exec stage now
               /* if(branch == 1) begin
                  //PCNxt = (Ext_dat << 2) + PCInc;
            PCNxt = BranchAddr;
                end else begin
                  PCNxt = PCInc;
                end
              end*/
          //Value from Register 31 -> Jump Return Addr
      2'b10: PCNxt = deif.busAOUT; //Intended to set Bus B to Reg31 for this instr
          //Go to location stored in register (some kind of program jump)
      2'b11: PCNxt = {deif.PCIncOUT[31:29],deif.InstructionOUT[25:0],2'b00}; //Set Bus A to wherever the ADDR is stored for this
    endcase
  end
  ////////////////////////
  /*	DECODE STAGE	*/
  ////////////////////////

  //Modules
  controller cntrl(
    .ctif(ctif)
  );

  //Register File Connection
  register_file REG1(
    .CLK(CLK),
    .nRST(nRST),
    .rfif(rfif1)
  );

  //  Connect Register File
  assign rfif1.WEN = mmif.writeRegOUT; //(ctif.writeReg & (dpif.dhit | dpif.ihit));
  assign rfif1.wsel = rw;//Check on mux for Rd/Rt
  assign rfif1.rsel1 = rs; //Rs
  assign rfif1.rsel2 = rt; //Rt
  assign rfif1.wdat = RegWDat;
  assign deif.busAIN = rfif1.rdat1;
  assign deif.busBIN = rfif1.rdat2;

  /* Decode Register Connections */
  //inputs
    assign deif.PCIncIN = feif.PCIncOUT;
    assign deif.InstructionIN = feif.InstructionOUT;
    assign deif.writeRegIN = ctif.writeReg;
    assign deif.MemtoRegIN = ctif.MemtoReg;
    assign deif.RegWDSelIN = ctif.RegWDsel;
    assign deif.dWENIN = ctif.dwritereq;
    assign deif.dRENIN = ctif.dreadreq;
    assign deif.PCSrcIN = ctif.PCSrc;
    assign deif.RegDstIN = ctif.RegDst;
    assign deif.ALUSrcIN = ctif.ALUSrc;
    assign deif.aluopIN = ctif.aluop;
    assign deif.Ext_datIN = Ext_dat;
    assign deif.rtIN = rt;
    assign deif.rdIN = rd;
    assign deif.opcodeIN = opcode;

// Signal names for decode stage
//	>Will be written into registers later if still needed
  assign opcode = feif.opcodeOUT;
  assign rs = feif.InstructionOUT[25:21];
  assign rt = feif.InstructionOUT[20:16];
  assign rd = feif.InstructionOUT[15:11];
  assign shamt = feif.InstructionOUT[10:6];
  assign funct = funct_t'(feif.InstructionOUT[5:0]);
  assign imm16 = feif.InstructionOUT[15:0];
  assign addr = feif.InstructionOUT[26:0];

  //Extender - Decode stage
  /*
    Extend with 0's if ExtOp = 1
    else preserve leading sign

  */
  always_comb begin
    if(ctif.ExtOp == 0) begin
      Ext_dat={16'h0000, imm16};
    end else if(imm16[15] == 1) begin
      Ext_dat={16'hFFFF, imm16};
    end else begin
      Ext_dat={16'h0000, imm16};
    end
  end

  /* FWDing Selection Muxes */
  //A
  always_comb begin
    if(huif.A_fw == 1) begin
      ALU_Ain = deif.busAOUT;
    end else begin
      ALU_Ain = huif.A_fwdata;
    end
  end
  //B
  always_comb begin
    if(huif.B_fw == 1) begin
      ALU_Bin = B_data;
    end else begin
      ALU_Bin = huif.B_fwdata;
    end
  end
  ////////////////////////
  /*	EXECUTE STAGE	*/
  ////////////////////////
  //Modules
  //ALU Connection
  alu ALU1(
    .A(ALU_Ain),
    .B(ALU_Bin),
    .aluop(deif.aluopOUT),
    .neg(neg),  //DC
    .overflow(overflow), //DC
    .zero(zero),
    .result(ALU_out)
    );
  //Register Connections
  //inputs
  assign exif.PCIncIN = deif.PCIncOUT;
  assign exif.writeRegIN = deif.writeRegOUT;
  assign exif.MemtoRegIN = deif.MemtoRegOUT;
  assign exif.RegWDSelIN = deif.RegWDSelOUT;
  assign exif.dWENIN = deif.dWENOUT;
  assign exif.dRENIN = deif.dRENOUT;
  assign exif.opcodeIN = deif.opcodeOUT;
  assign exif.busBIN = deif.busBOUT;
  assign exif.resultIN = result;
  //assign exif.RegDst = ;
  //outputs (not to next pipe register)
  //Ext_dat -> done in MUX, Lshift/adder for branchaddr
  //Bus_B -> Also used in mux
  //Rd -> used in RegDst MUX
  //Rt -> used in Regdst mux

  //Other signals
    //ALU Port B Selection MUX
    always_comb begin
      B_data = 32'hECE43700;
      casez(deif.ALUSrcOUT)
        2'b00: B_data = deif.busBOUT;
        2'b01: B_data = deif.Ext_datOUT;
        2'b10: B_data = {{25{1'b0}}, deif.InstructionOUT[10:6]}; //Shamt, easier to pull directly from instruction
        2'b11: B_data = '0; //Not connected to anything meaningful, should not be used
      endcase
    end
  //Register Write Location Select (exif.Rw)
  always_comb begin
    casez(deif.RegDstOUT)
      2'b00: exif.rwIN = deif.rtOUT;
      2'b01: exif.rwIN = deif.rdOUT;
      2'b10: exif.rwIN = 5'b11111;
      2'b11: exif.rwIN = 5'b00001;
      default:
        exif.rwIN = '0;
     endcase
  end
  	//Logic for result selection for LUI
  always_comb begin
    if(deif.opcodeOUT == LUI) begin
      result = {deif.InstructionOUT[15:0],16'h0000};
    end else begin
      result = ALU_out;
    end
  end
	//Calculate Branch Address (not always used)
  assign branchaddr = (deif.Ext_datOUT << 2) + deif.PCIncOUT;

  //Modify next PC Src if Branch taken or not
  //Generates PCSrc for use in IF
  always_comb begin
    PCSrc = 2'b00;
    if(deif.PCSrcOUT == 2'b01) begin
      if(branch == 1) begin
	//Branch taken -> keep current PCSrc
	//Flush needed for extra instructions grabbed
        PCSrc = deif.PCSrcOUT;
      end else begin
	//Keep selecting PC+4, no flush needed (currently) since no prediction logic
        PCSrc = 2'b00;
      end
    end else begin
      //Default is PCSrc is just what is set in controller
      PCSrc = deif.PCSrcOUT;
    end
  end
  	//Branch selection logic
  always_comb begin
    branch = 0;
    casez(deif.opcodeOUT)
      BEQ:  if(zero == 1) begin
              branch = 1;
            end
      BNE:  if(zero == 0) begin
              branch = 1;
            end
      default: branch = 0;
    endcase
  end

  ////////////////////////
  /*	MEMORY STAGE	*/
  ////////////////////////
  //Modules

  //Register Connections
  //inputs
  assign mmif.PCIncIN = exif.PCIncOUT;
  assign mmif.writeRegIN = exif.writeRegOUT;
  assign mmif.MemtoRegIN = exif.MemtoRegOUT;
  assign mmif.RegWDSelIN = exif.RegWDSelOUT;
  assign mmif.opcodeIN = exif.opcodeOUT;
  assign mmif.resultIN = exif.resultOUT;
  assign mmif.rwIN = exif.rwOUT;
  assign mmif.dmemloadIN = dpif.dmemload;


  //outputs (not to next pipe register)
  assign dpif.dmemstore = exif.busBOUT;
  assign dpif.dmemaddr = exif.resultOUT;

  ////////////////////////
  /*  Write Back STAGE	*/
  ////////////////////////
  //Modules

  //Register Connections
  //outputs (some of thse are feedback signals)
  assign rw = mmif.rwOUT;
  //Other signalsgit checkout origin/pipeline source/ram.sv

  //Register Data Write MUX
  always_comb begin
     casez(mmif.RegWDSelOUT)
       1'b0: RegWDat = dataout; //Select from mmif.<dmemload || result>
       1'b1: RegWDat = mmif.PCIncOUT; //mmif PC Inc
       default: RegWDat = dataout;
    endcase
  end

  //  Data Feedback to register select
  //  Need to assign based off of Mem Latch signals
  always_comb begin
    if(mmif.MemtoRegOUT == 1) begin
      dataout = mmif.dmemloadOUT;
    end else begin
      dataout = mmif.resultOUT;
    end
  end
  ////////////////////////////////
  /*    Hazard Detection Unit	*/
  ////////////////////////////////
	// Instantation
  hazard_unit hz1 (.CLK(CLK), .nRST(nRST), .huif(huif));
  assign huif.rs = rs;
  assign huif.rt = rt;
  assign huif.opcode = exif.opcodeIN; //From what stage
  assign huif.execDest = exif.rwIN;
  assign huif.memDest = mmif.rwIN;
  assign huif.MemRead_Ex = exif.MemtoRegIN;
  assign huif.MemRead_Mem = mmif.MemtoRegIN;
  assign huif.ihit = ihit;
  assign huif.dhit = dhit;
  assign huif.branch = branch;
  assign huif.writeReg_mem = exif.writeRegOUT;
  assign huif.writeReg_exec = deif.writeRegOUT;

  //Flush/Enable Signals
  //
  assign feif.flush = huif.fetch_flush & ihit;
  assign feif.enable = !huif.fetch_stall & ihit;
  assign deif.flush = huif.decode_flush & ihit;
  assign deif.enable = !huif.decode_stall & ihit;
  assign mmif.flush = huif.memory_flush & ihit;
  assign mmif.enable = !huif.memory_stall & (ihit | dhit);
  assign exif.flush = huif.execute_flush & (ihit | dhit);
  assign exif.enable = !huif.execute_stall & ihit;

  ////////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////
  /*    Datapath/Processor Running Logic	*/
  ////////////////////////////////////////////////

   //Troublesome, may be changed in pipeline now
  //assign deif.dRENIN = ctif.dreadreq;
  //assign deif.dWENIN = ctif.dwritereq;
  assign ihit = dpif.ihit; //could just directly use dpif.ihit/dhit
  assign dhit = dpif.dhit;


  /* Data Path (this module) Connections
    INPUTS -use to set stuff
      ihit - instruction fetched, does what???? not set I think
      imemload - data for instructions
      dhit - data fetched, use for RU
      dmemload - data for other use

    Outputs -generate these
      halt - set by controller
      imemREN - set by RU
      imemaddr - just the PC
      dmemREN - set by RU
      dmemWEN - set by RU
      datomic - set to 0 for now
      dmemstore - From busB
      dmemaddr
  */

  // Select when PC is on
  assign PCEn = !dpif.dhit & dpif.ihit & !huif.PCStall;//Need to add & !HazardStall

  //This should be fine since clocked to mmif Reg now
  always_comb begin
		if(mmif.opcodeOUT == HALT) begin
			dpif.halt = 1;
        end else begin
			dpif.halt = 0;
		end
  end

  assign ireadreq = !dpif.halt;

  //"Borrowed" and modified from Request Unit
  //this should work properly since halt is clocked based on mmif opcode
  always_ff @(posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.imemREN <= 0;
    end else if (ihit == 1) begin
      //Reset on ihit
      dpif.imemREN <= 0;
    end else begin
      dpif.imemREN <= ireadreq;
    end
  end

  //assign dpif.imemREN = iREN; //Need to generate this elsewhere now
  assign dpif.dmemREN = exif.dRENOUT;
  assign dpif.dmemWEN = exif.dWENOUT;
  assign dpif.imemaddr = PC;
  assign dpif.datomic = '0;

/* This should not be necessary, clocked to mmif now
  //always_ff @(negedge CLK, negedge nRST) begin
  always_ff @(posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.halt <= 0;
    //end else if (ruif.iREN == 0) begin
      //dpif.halt <= 1;
      //dpif.halt <= 1;
    end else begin
      if(mmif.opcode == HALT) begin
	dpif.halt <= 1;
      //dpif.halt <= 0;
    end
  end*/

 // assign dpif.halt = ctif.halt;//!ruif.iREN;//!ruif.iREN;


endmodule
