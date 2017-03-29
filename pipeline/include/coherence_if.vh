`ifndef COHERENCE_IF_VH
`define COHERENCE_IF_VH

`include "cpu_types_pkg.vh"
`include "caches_if.vh"

interface coherence_if;
  // import types
  import cpu_types_pkg::*;

  // access with cpuid on each processor
  parameter CPUS = 2;

  // arbitration
  logic   [CPUS-1:0]       iwait, dwait, iREN, dREN, dWEN;
  word_t  [CPUS-1:0]       iload, dload, dstore;
  word_t  [CPUS-1:0]       iaddr, daddr;

  // coherence
  // CPUS = number of cpus parameter passed from system -> cc
  // ccwait         : lets a cache know it needs to block cpu
  // ccinv          : let a cache know it needs to invalidate entry
  // ccwrite        : high if cache is doing a write of addr
  // ccsnoopaddr    : the addr being sent to other cache with either (wb/inv)
  // cctrans        : high if the cache state is transitioning (i.e. I->S, I->M, etc...)
  logic   [CPUS-1:0]      ccwait, ccinv;
  logic   [CPUS-1:0]      ccwrite, cctrans;
  word_t  [CPUS-1:0]      ccsnoopaddr;

  // ram side
  logic                   ramWEN, ramREN;
  ramstate_t              ramstate;
  word_t                  ramaddr, ramstore, ramload;

endinterface
`endif
