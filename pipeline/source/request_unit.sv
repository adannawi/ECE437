/*
    Noah Petersen

    request_unit.sv

    Handles raising/lowering signals for data/instruction requests.
*/

//Signals needed

/* Inputs
CLK, nRST,
dreadreq
dwritereq
ireadreq
dhit
ihit (just in case need later)
*/

/* Outputs
  dREN
  dWEN
  iREN
*/
`include "cpu_types_pkg.vh"
`include "request_unit_if.vh"
import cpu_types_pkg::*;

module request_unit (
  input CLK, nRST,
  request_unit_if.ru ruif
);
  //previous import
  //assign ruif.iREN = ruif.ireadreq;


/*
  assign deif.enable = ihit && (hu.enable)  
*/
//assign ruif.iREN = ruif.ireadreq & !ruif.ihit; //Ignoring ihit for now

  always_ff @(posedge CLK, negedge nRST) begin
    //ruif.dREN <= 0;
    //ruif.dWEN <= 0;
    if(nRST == 0) begin
      ruif.dREN <= 0;
      ruif.dWEN <= 0;
      //ruif.iREN = 0;
    end else begin
      if(ruif.dhit == 1) begin
        ruif.dREN <= 0;
        ruif.dWEN <= 0;
      end else if(ruif.ihit == 1) begin
        ruif.dREN <= ruif.dreadreq;
        ruif.dWEN <= ruif.dwritereq;
      end else begin
	//Assign default of hold same value (for variable latency)
  //Should be handled by waiting for dhit before flushing ex reg
				ruif.dREN <= ruif.dREN;
				ruif.dWEN <= ruif.dWEN;
      end
    end
  end
endmodule
