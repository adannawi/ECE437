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
`include "fetch_if.vh"
`include "execute_if.vh"

// alu op, mips op, and instruction type
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
  word_t ALU_Bin;
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

  //    Register file interface
  register_file_if rfif1 ();

  //    Controller Interface
  controller_if ctif ();

  //    Request Unit Interface
  request_unit_if ruif ();

  //    Fetch Reg interface
  fetch_if.fif feif ();

  //    Decode Reg interface
  decode_if.dif deif ();

  //    Execute Reg interface
  execute_if.eif exif ();

  //    Mem Reg interface
  mem_if.mif mmif ();

  //  Controller Signals
  opcode_t opcode;

  logic branch;

  //Request unit signals ->desired in order to manage timing of reads/writes
  //logic ireadreq;
  //logic dreadreq;
  //logic dwritereq;

  //    Instruction type delarations & Related signals


///////////////////////////////////////////////////////////////////////

  //Pipeline Register Bank Instances
  mem_registers mem1 (CLK, nRST, mmif);
  decode_registers dc1 (CLK, nRST, deif);
  execute_registers exc1 (CLK, nRST, exif);
  fetch_registers fch1 (CLK, nRST, feif);

  ////////////////////////
  /*	FETCH STAGE	*/
  ////////////////////////

  //Modules

  /*	Fetch Register Connections */
  //inputs
  assign feif.instructionIN = dpif.imemload;
  assign feif.PCIncIN = PCInc;

  //outputs (not to next pipe register)
  assign ctif.instruction = feif.instructionOUT;

  //NEED TO INSERT DPIF SIGNALS FOR INTERFACING TO IMEM
	//Need to add in remainer of signals needed to interface to Instruction memor (via dpif)
	
  //PC Nxt Standard Update <- These may need to change
  assign PCInc = PC + 4;

  // Select when PC is on
  assign PCEn = !dpif.dhit & dpif.ihit;//!dpif.halt & (!dpif.dhit & dpif.ihit);

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
                if(branch == 1) begin
                  //PCNxt = (Ext_dat << 2) + PCInc;
		  PCNxt = BranchAddr;
                end else begin
                  PCNxt = PCInc;
                end
              end
          //Value from Register 31 -> Jump Return Addr
      2'b10: PCNxt = busA; //Intended to set Bus B to Reg31 for this instr
          //Go to location stored in register (some kind of program jump)
      2'b11: PCNxt = {PCInc[31:28],addr,2'b00}; //Set Bus A to wherever the ADDR is stored for this
    endcase
  endv
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
  assign rfif1.WEN = //(ctif.writeReg & (dpif.dhit | dpif.ihit));
  assign rfif1.wsel = rw;//Check on mux for Rd/Rt
  assign rfif1.rsel1 = rs; //Rs
  assign rfif1.rsel2 = rt; //Rt
  assign rfif1.wdat = RegWDat;
  assign deif.busA = rfif1.rdat1;
  assign deif.busB = rfif1.rdat2;

  /* Decode Register Connections */
  //inputs
    assign deif.PCIncIN = feif.PCIncOUT;
    assign deif.InstructionIN = feif.instructionOUT;
    assign deif.writeRegIN = ctif.writeReg;
    assign deif.MemtoRegIN = ctif.MemtoRegIN;
    assign deif.RWDSelIN = ctif.RWDSelIN;
    assign deif.dWENIN = ctif.dwritereq;
    assign deif.dRENIN = ctif.dreadreq;
    assign deif.PCSrcIN = ctif.PCSrc;
    assign deif.RegDstIN = ctif.RegDst;
    assign deif.ALUSrcIN = ctif.ALUSrc;
    assign deif.aluopIN = ctif.aluop;
    assign deif.ext_datIN = Ext_dat;
    assign deif.busAIN = rfif.rdat1;
    assign deif.busBIN = rfif.rdat2;
    assign deif.RtIN = rt;
    assign deif.RdIN = rd;

// Signal names for decode stage
//	>Will be written into registers later if still needed
  assign opcode = opcode_t'(feif.instructionOUT[31:26]);
  assign rs = feif.instructionOUT[25:21];
  assign rt = feif.instructionOUT[20:16];
  assign rd = feif.instructionOUT[15:11];
  assign shamt = feif.instructionOUT[10:6];
  assign funct = funct_t'(feif.instructionOUT[5:0]);
  assign imm16 = feif.instructionOUT[15:0];
  assign addr = feif.instructionOUT[26:0];

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

  ////////////////////////
  /*	EXECUTE STAGE	*/
  ////////////////////////
  //Modules
  //ALU Connection
  alu ALU1(
    .A(deif.busAOUT),
    .B(ALU_Bin),
    .aluop(deif.aluopOUT), 
    .neg(neg),  //DC
    .overflow(overflow), //DC
    .zero(zero),
    .result(ALU_out)
    );
  //Register Connections
  //inputs
  assign exif.PCIncIN =
  assign exif.writeRegIn =
  assign exif.MemtoRegIN =
  assign exif.RWDSelIN =
  assign exif.dWENIN =
  assign exif.dRENIN =
  assign exif.opcodeIN =
  assign exif.busBIN =
  assign exif.resultIN =
  //outputs (not to next pipe register)

  //Other signals
    //ALU Port B Selection MUX
    always_comb begin
      casez(ctif.ALUSrc)
        2'b00: ALU_Bin = deif.busB;
        2'b01: ALU_Bin = deif.Ext_dat;
        2'b10: ALU_Bin = deif.instruction[10:6]; //Shamt, easier to pull directly from instruction
        2'b11: ALU_Bin = '0;
      endcase
    end
  //Register Write Location Select (Rw)
  always_comb begin
    casez(deif.RegDst)
      2'b00: rw = deif.RtOUT;
      2'b01: rw = deif.RdOUT;
      2'b10: rw = 5'b11111;
      2'b11: rw = 5'b00001;
      default:
        rw = '0;
     endcase
  end
  	//Logic for result selection for LUI
  always_comb begin
    if(deif.opcode == LUI) begin
      result = {imm16,16'h0000};
    end else begin
      result = ALU_out;
    end
  end
	//Calculate Branch Address
  assign BranchAddr = (deif.Ext_dat << 2) + deif.PCInc;

	//Modify next PC Src if Branch taken or not
  always_comb begin
    PCSrc = 2'b00;
    if(deif.PCSrc == 2'b01) begin
      if(branch == 1) begin
        PCSrc = deif.PCSrc;
      end else begin
        PCSrc = 2'b00;
      end
    end else begin
      PCSrc = deif.PCSrc;
    end
  end
  	//Branch selection logic
  always_comb begin
    branch = 0;
    casez(opcode)
      BEQ:  if(zero == 1) begin
              branch = 1;
            end
      BNE:  if(zero == 0) begin
              branch = 1;
            end
    endcase
  end

  ////////////////////////
  /*	MEMORY STAGE	*/
  ////////////////////////
  //Modules
 
  //Register Connections
  //inputs
  assign mmif.PCIncIN = exif.PCIncOUT;
  assign mmif.writeRegIN =
  assign mmif.MemtoRegIN =
  assign mmif.RWDSelIN =
  assign mmif.opcodeIN =
  assign mmif.resultIN = exif.resultOUT;
  assign mmif.rwIN =
  assign mmif.dmemloadIN = dpif.dmemload;

  //outputs (not to next pipe register)

  //Other signals
  assign dpif.dmemstore = exif.busBOUT;
  assign dpif.dmemaddr = exif.resultIN;
  
  ////////////////////////
  /*  Write Back STAGE	*/
  ////////////////////////
  //Modules

  //Register Connections
  //inputs <- NA
  //outputs

  //Other signals
  //Register Data Write MUX
  always_comb begin
     casez(mmif.RegWDsel)
      1'b0: RegWDat = dataout; //Select from mmif.<dmemload || result>
      1'b1: RegWDat = mmif.PCInc; //mmif PC Inc
    endcase
  end

  //  Data Feedback to register select
  //  Need to assign based off of Mem Latch signals
  always_comb begin
	if(mmif.MemtoReg == 1) begin
		dataout = mmif.dmemload;
	end else begin
		dataout = mmif.result;
	end
  end
  ////////////////////////////////
  /*    Hazard Detection Unit	*/
  ////////////////////////////////
  //Flush/Enable Signals
  //


  ////////////////////////////////////////////////////////////////////////////////

  assign ruif.ireadreq = !dpif.halt; //Troublesome, may be changed in pipeline now
  //assign ruif.dreadreq = ctif.dreadreq;
  //assign ruif.dwritereq = ctif.dwritereq;
  assign deif.dREN = ctif.dreadreq;
  assign deif.dWEN = ctif.dwritereq;
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

  //always_ff @(negedge CLK, negedge nRST) begin
  always_ff @(posedge CLK, negedge nRST) begin
    if(nRST == 0) begin
      dpif.halt <= 0;
    //end else if (ruif.iREN == 0) begin
      //dpif.halt <= 1;
      //dpif.halt <= 1;
    end else begin
      dpif.halt <= ctif.halt;
      //dpif.halt <= 0;
    end
  end

 // assign dpif.halt = ctif.halt;//!ruif.iREN;//!ruif.iREN;
  assign dpif.imemREN = iREN; //Need to generate this elsewhere now
  assign dpif.dmemREN = exif.dREN;
  assign dpif.dmemWEN = exif.dWEN;
  assign dpif.imemaddr = PC;
  assign dpif.datomic = '0;

endmodule
