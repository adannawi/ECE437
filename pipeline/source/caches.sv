/*
  Eric Villasenor
  evillase@gmail.com

  this block holds the i and d cache
*/


module caches (
  input logic CLK, nRST,
  //datapath_cache_if.cache dcif,
  datapath_cache_if dcif,
  caches_if cif
);
  //caches_if.icache dicif(); //datapath icache interface
  //caches_if.dcache ddcif(); //Datapath dcache interface
  //What we care about for CIF (single core)
  /*
    inputs
      iwait
      iload
      dwait
      dload

    outputs
      dREN
      dWEN
      daddr
      dstore
      iREN
      iaddr
  */

  // icache
  icache  ICACHE(CLK, nRST, dcif, cif);
  // dcache
  dcache  DCACHE(CLK, nRST, dcif, cif);

  // dcache invalidate before halt handled by dcache when exists
  //assign dcif.flushed = dcif.halt;


  //singlecycle -> all these signals driven in icache or dcache now
  //assign dcif.ihit = (dcif.imemREN) ? ~cif.iwait : 0;
  //assign dcif.dhit = (dcif.dmemREN|dcif.dmemWEN) ? ~cif.dwait : 0;
  //assign dcif.imemload = cif.iload;
  //assign dcif.dmemload = cif.dload;

  //assign cif.iREN = dcif.imemREN;
  //assign cif.dREN = dcif.dmemREN;
  //assign cif.dWEN = dcif.dmemWEN;
  //assign cif.dstore = dcif.dmemstore;
  //assign cif.iaddr = dcif.imemaddr;
  //assign cif.daddr = dcif.dmemaddr;

endmodule
