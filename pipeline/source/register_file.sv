//Author: Noah Petersen
//Description:  Register file for single cycle processor (and potentially beyond)
//              made as part of lab 1.

`include "register_file_if.vh"
import cpu_types_pkg::*;

module register_file

  //Import register IF ~ this file also includes cpu_types_pkg.vh
  (
    input logic CLK, nRST,
    register_file_if.rf rfif
  );
  //Example reference for IF:
  //rfif.WEN = 0;

  //Local Variables
  word_t regs [31:0];

  //RDAT1 MUX
  always_comb begin
    rfif.rdat1 = regs[rfif.rsel1];
  end

  //RDAT2 MUX
  always_comb begin
    rfif.rdat2 = regs[rfif.rsel2];
  end

  //Registers
  //  (Reg00 ALWAYS 0)
  //  Might want to simplify this and remove decoder logic from here?
  //  How else to indicate which block to update though?i
  //  Would need to find a next value for each... this is easier to write for
  //  sure.

  //always_ff @(posedge CLK, negedge nRST) begin  //original
  always_ff @(negedge CLK, negedge nRST) begin

    //Reset Regs
    if(nRST == 0) begin
      regs <= '{default:0};

    //Update values if WEN == 1
    end else begin
      //Avoid latches, always update everything in either branch
      regs <= regs;

      //Write value if enabled
      if(rfif.WEN == 1) begin

        if(rfif.wsel == 0) begin
          //Keep reg0 as 0
          regs[0]  <= '0;
        end else begin
          //Update non-zero reg value
          regs[rfif.wsel] <= rfif.wdat;
        end

      end

    end

  end


endmodule
