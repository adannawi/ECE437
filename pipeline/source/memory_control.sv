/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"

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
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if.cc ccif //Includes interface to ram (ram_if)
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cciload, d
  parameter CPUS = 1; //Do we wnat to change this

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

assign ccif.ccwait = '0; //Set to 0 for now
assign ccif.ccinv = '0;  //Set to 0 for now
assign ccif.ccsnoopaddr = '0;    //Set to 0 for now
//Output Logic


//Try to do these using assign statements
//assign ccif.ramREN = (ccif.dREN | (ccif.iREN & !ccif.dWEN));
//assign ccif.ramWEN = (ccif.dWEN & (!ccif.dREN));
assign ccif.ramREN = ccif.dREN | (ccif.iREN & !ccif.dWEN);
assign ccif.ramWEN = ccif.dWEN;

assign ccif.iload = ccif.ramload; //Assume processor will know what to check
assign ccif.dload = ccif.ramload; // ^^^
assign ccif.ramstore = ccif.dstore;


//Arbitrate ram addr
always_comb begin
  if((ccif.dREN == 1) || (ccif.dWEN == 1)) begin
    ccif.ramaddr = ccif.daddr;
  end else begin
    ccif.ramaddr = ccif.iaddr;
  end
end

//iwait
always_comb begin
  ccif.iwait = 0;
  if ((ccif.dREN == 1) || (ccif.dWEN == 1)) begin
    if (ccif.iREN == 1) begin
      ccif.iwait = 1;
    end
  end else if (ccif.iREN == 1) begin
    //RAM state dependent
    if (ccif.ramstate == FREE) begin
      //If want a request but ram hasnt registered yet
      ccif.iwait = 1;
    end else if (ccif.ramstate == BUSY) begin
      //Waiting for RAM to respond
      ccif.iwait = 1;
    end else if (ccif.ramstate == ACCESS) begin
      ccif.iwait = 0;
    end else begin
      //Error state, probably not good to register this
      ccif.iwait = 1;
    end
  end else begin
    //No request, no issues there
    ccif.iwait = 0;
  end
end

//dwait
always_comb begin
    ccif.dwait = 0;
  if((ccif.dREN == 1) || (ccif.dWEN == 1)) begin
    //RAM State dependent
    if(ccif.ramstate == FREE) begin
      //If want a request but ram hasnt registered yet
      ccif.dwait = 1;
    end else if(ccif.ramstate == BUSY) begin
      //Waiting for RAM to respond
      ccif.dwait = 1;
    end else if(ccif.ramstate == ACCESS) begin
      //RAM returned
      ccif.dwait = 0;
    end else begin
      //Error state, probably not good to register this
      ccif.dwait = 1;
    end
  end
end


endmodule
