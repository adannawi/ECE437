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
    ARBITRATE = 3'b010,
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

//assign ccif.ccwait = '0; //Set to 0 for now
//assign ccif.ccinv = '0;  //Set to 0 for now
//assign ccif.ccsnoopaddr = '0;    //Set to 0 for now
//Output Logic


//Try to do these using assign statements
//assign ccif.ramREN = (ccif.dREN | (ccif.iREN & !ccif.dWEN));
//assign ccif.ramWEN = (ccif.dWEN & (!ccif.dREN));

assign mmif.ramREN = ccif.dREN | (ccif.iREN & !ccif.dWEN);
assign mmif.ramWEN = ccif.dWEN;
always_comb begin
    mmif.iload[servicing] = ccif.ramload; //Assume processor will know what to check
    mmif.dload[servicing] = ccif.ramload; // ^^^
end
assign mmif.ramstore = ccif.dstore[servicing];


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
  ccif.iwait[servicing] = 1;
  if (ccif.iREN[~servicing]) begin
    ccif.iwait[~servicing] = 1;
  end
  if ((ccif.dREN[servicing] == 1) || (ccif.dWEN[servicing] == 1)) begin
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
  ccif.dwait[servicing] = 0;
  if (ccif.dWEN[~servicing] | ccif.dREN[~servicing]) begin
    ccif.dwait[~servicing] = 1;
  end
  if((ccif.dREN[servicing] == 1) || (ccif.dWEN[servicing] == 1)) begin
    //RAM State dependent
    if(ccif.ramstate == FREE) begin
      //If want a request but ram hasnt registered yet
      ccif.dwait[servicing] = 1;
    end else if(ccif.ramstate == BUSY) begin
      //Waiting for RAM to respond
      ccif.dwait[servicing] = 1;

    end else if(ccif.ramstate == ACCESS) begin
      //RAM returned
      ccif.dwait[servicing] = 0;
    end else begin
      //Error state, probably not good to register this
      ccif.dwait[servicing] = 1;
    end
  end
end

///////////////////////////////////////////////////////////////////////
////////////////// CACHE COHERENCE SECTION   //////////////////////////

// Assigns //

assign coif.ramstate = ccif.ramstate;

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
          nextstate = ARBITRATE;
        end
        end
    ARBITRATE: begin
        nextstate = SNOOP;
        end
    SNOOP: begin
        if (ccif.ccwrite[~servicing]) begin
          nextstate = CTC1;
        end else if (ccif.ccwrite[servicing]) begin
          nextstate = MEM1;
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
    end // default:
  ARBITRATE: begin
    coif.ccwait[~servicing] = 1;
    coif.ccinv[~servicing] = ccif.ccwrite[servicing];
  end
  SNOOP: begin
    coif.ccsnoopaddr[~servicing] = ccif.daddr[servicing];
  end
  CTC1: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = ccif.dstore[~servicing];
    coif.ramWEN = 1;
    coif.dload[servicing] = ccif.dstore[~servicing];
  end
  CTC2: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = ccif.dstore[~servicing];
    coif.ramWEN = 1;
    coif.dload[servicing] = ccif.dstore[~servicing]; 
  end
  MEM1: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = 0;
    coif.ramREN = 1;
    coif.dload[servicing] = ccif.ramload;
  end
  MEM2: begin
    coif.ramaddr = ccif.daddr[~servicing];
    coif.ramstore = 0;
    coif.ramREN = 1;
    coif.dload[servicing] = ccif.ramload; 
  end
  default: begin
    coif.ccwait[~servicing] = 0;
    coif.ccinv[~servicing] = 0;
    coif.ccsnoopaddr[~servicing] = 0;
    coif.ramaddr = 0;
    coif.ramstore = 0;
    coif.ramWEN = 0;
    coif.ramREN = 0;
    coif.dload[servicing] = 0s;
  end    
endcase
end 

//////////      MUX BETWEEN SIGNALS       ////////////
always_comb begin
    if (state != IDLE) begin // We're being coherent
      ccif.ramaddr = coif.ramaddr;
      ccif.ramstore = coif.ramstore;
      ccif.ramWEN = coif.ramWEN;
      ccif.ramREN = coif.ramREN;
      ccif.dload[servicing] = coif.dload[servicing];
    end else begin // No coherence
      ccif.ramaddr = mmif.ramaddr;
      ccif.ramstore = mmif.ramstore;
      ccif.ramWEN = mmif.ramWEN;
      ccif.ramREN = mmif.ramREN;
      ccif.dload[servicing] = mmif.dload[servicing];
      // other stuff
    end

end
endmodule
