/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/



/* Signal groupings - inputs and outputs shown from ccif perspective
      Once the relationships for these signals are understood, it should be an
easy module to write
  //Cache I-->O
  iREN        iwait
  iaddr       dwait
  daddr       iload
  dstore      dload
  dREN
  dWEN

  //Cache coherence I-->O
  ccwrite     ccwait
  cctrans     ccinv
              ccsnoopaddr

  //Ram Control signals from Ram_if I-->O
  ramload     ramstore
  ramstate    ramaddr
              ramWEN
              ramREN

  //Word_t type is [31:0] logic

  //  Ram - interfaces to ram using these signals based on signals from
  //        processor (via cache)
  // ramaddr - (word_t)
  // ramload - (word_t)
  // ramstate - states of ram: FREE (00), BUSY (01), ACCESS (10), ERROR (11)
  // ramstore - (word_t)
  // ramWEN - Write enable for ram
  // ramREN - Read enable

  //  coherence
  // CPUS = number of cpus parameter passed from system -> cc
  // ccwait         : lets a cache know it needs to block cpu
  // ccinv          : let a cache know it needs to invalidate entry
  // ccwrite        : high if cache is doing a write of addr
  // ccsnoopaddr    : the addr being sent to other cache with either (wb/inv)
  // cctrans        : high if the cache state is transitioning (i.e. I->S, I->M, etc...)

  // Instruction signals
  // iren  - read from iaddr when this is asserted
  // iaddr -
  // instr - output instruction from ram on here
  // iwait - assert while instruction is being fetched/until ready to relase
*/

// memory types
// interface include
`include "cache_control_if.vh"
`include "caches_if.vh"
`include "cpu_types_pkg.vh"
`include "coherence_if.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif //Includes interface to ram (ram_if)
);
  // type import
  import cpu_types_pkg::*;
  coherence_if coif();
  coherence_if mmif();
  // number of cpus for cciload, d
  parameter CPUS = 2; 


  // COHERENCE CONTROL SIGNALS //

  typedef enum logic [2:0]{
    IDLE = 3'b001,
    INV = 3'b010,
    SNOOP = 3'b011,
    CTC1 = 3'b100,
    CTC2 = 3'b101,
    MEM1 = 3'b110,
    MEM2 = 3'b111
  } StateType;

  StateType state, nextstate;
  logic nextservice; //set which cache is being serviced
  logic servicing;
  logic decide;
  logic dreq[1:0];
  logic ireq[1:0];



/* Control signals
  dREN
  dWEN
  iREN
  ramstate
  ccwrite
  cctrans

  //  coherence
  // CPUS = number of cpus parameter passed from system -> cc
  // ccwait         : lets a cache know it needs to block cpu
  // ccinv          : let a cache know it needs to invalidate entry
  // ccwrite        : high if cache is doing a write of addr
  // ccsnoopaddr    : the addr being sent to other cache with either (wb/inv)
  // cctrans        : high if the cache state is transitioning (i.e. I->S, I->M, etc...)
*/

//MMIF inputs
assign mmif.iREN = ccif.iREN;
assign mmif.dREN = ccif.dREN;
assign mmif.dWEN = ccif.dWEN;
assign mmif.dstore = ccif.dstore;
assign mmif.iaddr = ccif.iaddr;
assign mmif.daddr = ccif.daddr;
assign mmif.ramload = ccif.ramload;
assign mmif.ramstate = ccif.ramstate;
assign mmif.ccwrite = ccif.ccwrite;
assign mmif.cctrans = ccif.cctrans;

//COIF Inputs
assign coif.iREN = ccif.iREN;
assign coif.dREN = ccif.dREN;
assign coif.dWEN = ccif.dWEN;
assign coif.dstore = ccif.dstore;
assign coif.iaddr = ccif.iaddr;
assign coif.daddr = ccif.daddr;
assign coif.ramload = ccif.ramload;
assign coif.ramstate = ccif.ramstate;
assign coif.ccwrite = ccif.ccwrite;
assign coif.cctrans = ccif.cctrans;

//Pass through outputs for ccif (mainly instructions (confirm))
assign ccif.iload[0] = ccif.ramload;
assign ccif.iload[1] = ccif.ramload;


//assign ccif.ccwait = '0; //Set to 0 for now
//assign ccif.ccinv = '0;  //Set to 0 for now
//assign ccif.ccsnoopaddr = '0;    //Set to 0 for now
//Output Logic


//Try to do these using assign statements
//assign ccif.ramREN = (ccif.dREN | (ccif.iREN & !ccif.dWEN));
//assign ccif.ramWEN = (ccif.dWEN & (!ccif.dREN));

assign mmif.ramREN = ccif.dREN[servicing] | (ccif.iREN[servicing] & !ccif.dWEN[servicing]);
assign mmif.ramWEN = ccif.dWEN[servicing];
assign mmif.ramstore = ccif.dstore[servicing];

assign mmif.dload[0] = mmif.ramload;
assign mmif.dload[1] = mmif.ramload;



///////////////////////// Memory Controller  ////////////////////////////
//Arbitrate ram addr
always_comb begin
  if((ccif.dREN[servicing] == 1) || (ccif.dWEN[servicing] == 1)) begin
    mmif.ramaddr = ccif.daddr[servicing];
  end else begin
    mmif.ramaddr = ccif.iaddr[servicing];
  end
end

//iwait
always_comb begin
  ccif.iwait = '0;
  if (ccif.iREN[~servicing]) begin
    ccif.iwait[~servicing] = 1;
  end
  if (ccif.dREN[servicing] || ccif.dWEN[servicing]) begin
    if (ccif.iREN[servicing] == 1) begin
      ccif.iwait[servicing] = 1;
    end
  end else if (ccif.iREN[servicing] == 1) begin
    //RAM state dependent
    if (ccif.ramstate == FREE) begin
      //If want a request but ram hasnt registered yet
      ccif.iwait[servicing] = 1;
    end else if (ccif.ramstate == BUSY) begin
      //Waiting for RAM to respond
      ccif.iwait[servicing] = 1;
    end else if (ccif.ramstate == ACCESS) begin
      ccif.iwait[servicing] = 0;
    end else begin
      //Error state, probably not good to register this
      ccif.iwait[servicing] = 1;
    end
  end else begin
    //No request, no issues there
    ccif.iwait[servicing] = 0;
  end
end

//dwait
always_comb begin
  mmif.dwait = '0;
  if (ccif.dWEN[~servicing] | ccif.dREN[~servicing]) begin
    mmif.dwait[~servicing] = 1;
  end
  if((ccif.dREN[servicing] == 1) || (ccif.dWEN[servicing] == 1)) begin
    //RAM State dependent
    if(ccif.ramstate == FREE) begin
      //If want a request but ram hasnt registered yet
      mmif.dwait[servicing] = 1;
    end else if(ccif.ramstate == BUSY) begin
      //Waiting for RAM to respond
      mmif.dwait[servicing] = 1;

    end else if(ccif.ramstate == ACCESS) begin
      //RAM returned
      mmif.dwait[servicing] = 0;
    end else begin
      //Error state, probably not good to register this
      mmif.dwait[servicing] = 1;
    end
  end
end

///////////////////////////////////////////////////////////////////////
////////////////// CACHE COHERENCE SECTION   //////////////////////////

// Assigns //

//assign coif.ramstate = ccif.ramstate;

// Need to assign servicing round robin (currently set in state machine)
assign dreq[0] = (ccif.dWEN[0] || ccif.dREN[0]);
assign dreq[1] = (ccif.dWEN[1] || ccif.dREN[1]);
assign ireq[0] = ccif.iREN[0];
assign ireq[1] = ccif.iREN[1];

// Combinational block to set servicing
always_comb begin
  if (dreq[0] && !dreq[1]) begin
    servicing = 0;
  end else if (!dreq[0] && dreq[1]) begin
    servicing = 1;
  end else if ((dreq[0] && dreq[1]) || (ireq[0] && ireq[1])) begin
    servicing = nextservice;
  end else if (ireq[0] && !ireq[1]) begin
    servicing = 0;
  end else if (!ireq[0] && ireq[1]) begin
    servicing = 1;
  end else begin
    servicing = nextservice;
  end
end

// State Register //
always_ff @ (posedge CLK, negedge nRST) begin
  if (nRST == 0) begin
    state <= IDLE;


    nextservice <= 0;
  end else begin
    state <= nextstate;



    if (!ccif.iwait[servicing] && ccif.ramstate == ACCESS) begin
      nextservice <= ~servicing;
    end else if (((state == CTC2) || (state == MEM2)) && (nextstate == IDLE)) begin
      nextservice <= ~servicing;
    end else begin
      nextservice <= nextservice;
    end
  end
end // always_ff @ (posedge CLK, negedge nRST)


// Next State Logic
always_comb begin
  nextstate = state;
  casez(state)
    IDLE: begin
        if (ccif.cctrans[1] || ccif.cctrans[0]) begin
          nextstate = SNOOP;
        end
        end
    SNOOP: begin
        if (ccif.ccwrite[~servicing]) begin
          nextstate = CTC1;
        end else if (!ccif.ccwrite[servicing] && !ccif.ccwrite[~servicing]) begin
          nextstate = MEM1;
        end else if (ccif.ccwrite[servicing]) begin
          nextstate = INV;
        end
        end
    CTC1: begin
        if (!ccif.dwait[servicing]) begin
          nextstate = CTC2;
        end
        end
    CTC2: begin
        if (!ccif.dwait[servicing]) begin
          nextstate = IDLE;
        end
        end
    MEM1: begin
        if (!ccif.dwait[servicing]) begin
          nextstate = MEM2;
        end
        end
    MEM2: begin
        if (!ccif.dwait[servicing]) begin
          nextstate = IDLE;
        end
        end
    default: begin
        nextstate = state;
        end
    endcase
end // always_comb

// Output Logic
always_comb begin
  // Defaults here
  coif.ccwait = '0;
  coif.ccinv = '0;
  coif.ccsnoopaddr = '0;
  coif.ramaddr = '0;
  coif.ramstore = '0;
  coif.ramWEN = '0;
  coif.ramREN = '0;
  coif.dload = ccif.daddr[servicing];
  coif.dwait = 0;
  casez(state)
  IDLE: begin
    coif.ccwait[~servicing] = 0;
    coif.ccinv[~servicing] = 0;
    coif.ccsnoopaddr[~servicing] = 0;
    coif.ramaddr = 0;
    coif.ramstore = 0;
    coif.ramWEN = 0;
    coif.ramREN = 0;
    coif.dload[servicing] = 0;
    coif.dwait[servicing] = 0;
    coif.dwait[~servicing] = 0;
    end // default:
    /*
  ARBITRATE: begin
    coif.ccwait[~servicing] = 1;
    coif.ccinv[~servicing] = ccif.ccwrite[servicing];
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
    coif.dwait[servicing] = 1;
    coif.dwait[~servicing] = 1;
    */ // ded
  end
  SNOOP: begin
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
    coif.ccwait[~servicing] = 1;
    coif.dwait[servicing] = 1;
    coif.dwait[~servicing] = 1;
  end
  INV: begin
    coif.ccinv[~servicing] = 1;
    coif.ccinv[servicing] = 0;
  end
  CTC1: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = ccif.dstore[~servicing];
    coif.ramWEN = 1;
    coif.dload[servicing] = ccif.dstore[~servicing];
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
    coif.ccwait[~servicing] = 1;
    coif.dwait[servicing] = mmif.dwait[servicing];
    coif.dwait[~servicing] = mmif.dwait[servicing];
  end
  CTC2: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = ccif.dstore[~servicing];
    coif.ramWEN = 1;
    coif.dload[servicing] = ccif.dstore[~servicing]; 
    coif.ccwait[~servicing] = 1;
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
    coif.ccinv[~servicing] = 1;
    coif.dwait[servicing] = mmif.dwait[servicing];
    coif.dwait[~servicing] = mmif.dwait[servicing];
  end
  MEM1: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = 0;
    coif.ramREN = 1;
    coif.dload[servicing] = ccif.ramload;
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
    coif.ccwait[~servicing] = 1;
    coif.dwait[servicing] = mmif.dwait[servicing];
    coif.dwait[~servicing] = mmif.dwait[~servicing];
  end
  MEM2: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = 0;
    coif.ramREN = 1;
    coif.dload[servicing] = ccif.ramload;
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
    coif.ccwait[~servicing] = 1;
    coif.dwait[servicing] = mmif.dwait[servicing];
    coif.dwait[~servicing] = mmif.dwait[~servicing];
  end
  default: begin
    coif.ccwait[~servicing] = 0;
    coif.ccinv[~servicing] = 0;
    coif.ccsnoopaddr[~servicing] = 0;
    coif.ramaddr = 0;
    coif.ramstore = 0;
    coif.ramWEN = 0;
    coif.ramREN = 0;
    coif.dload[servicing] = 0;
    coif.dwait[servicing] = 0;
    coif.dwait[~servicing] = 0;
  end    
endcase
end 

//CC Snooping Signals
assign ccif.ccsnoopaddr = coif.ccsnoopaddr;
assign ccif.ccwait = coif.ccwait;
assign ccif.ccinv = coif.ccinv;

//////////      MUX BETWEEN SIGNALS       ////////////
always_comb begin

    /*
    ccif.ramaddr = '0;
    ccif.ramstore = '0;
    ccif.ramWEN = '0;
    ccif.ramREN = '0;
    ccif.dload = '0;
    */

    if (state != IDLE) begin // We're being coherent
      ccif.ramaddr = coif.ramaddr;
      ccif.ramstore = coif.ramstore;
      ccif.ramWEN = coif.ramWEN;
      ccif.ramREN = coif.ramREN;
      ccif.dload = coif.dload;
      ccif.dwait[0] = coif.dwait[0];
      ccif.dwait[1] = coif.dwait[1];
    end else begin // No coherence
      ccif.ramaddr = mmif.ramaddr;
      ccif.ramstore = mmif.ramstore;
      ccif.ramWEN = mmif.ramWEN;
      ccif.ramREN = mmif.ramREN;
      ccif.dload = mmif.dload;
      ccif.dwait[0] = mmif.dwait[0];
      ccif.dwait[1] = mmif.dwait[1];

      // other stuff
    end
      
end
endmodule








