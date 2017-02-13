/*
  Noah Petersen
  peter248

  ALU fpga wrapper
*/
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

// No interface
module alu_fpga
(
  //Note that these are FPGA modules/Hardware Definitions
  input logic  [3:0] KEY,   //Input for ALUOP
  input logic [17:0] SW,    //Input for A/B
  output logic [2:0] LEDR,   //Output for Flags
  output logic [6:0] HEX0,
  output logic [6:0] HEX1,
  output logic [6:0] HEX2,
  output logic [6:0] HEX3,
  output logic [6:0] HEX4,
  output logic [6:0] HEX5,
  output logic [6:0] HEX6,
  output logic [6:0] HEX7
);

/* FPGA Portmap
  Key3..Key0 -> to ALUOP
  Port A -> 16 x SW16,SW15,..SW9
  Port B -> 16 x SW8,SW7,..SW0
  Register B WE: SW17
  Output 7-Seg Display (how to map exactly?) -> Ask in Office Hours
*/

//Define Signals
  logic [31:0] result; //Connect all to output HEX
  logic [31:0] A; //Only connect 16 bits
  logic [31:0] B; //Connect to A, set by SW 17 POSEDGE
  aluop_t aluop;
  logic neg;
  logic overflow;
  logic zero;

//Define Connections to TestBench (?)
  alu ALU1(
    //Define Signals
      .A(A),              //Only 16 bits actually assigned
      .B(B),              //Only 16 bits of this will be actually assigned
      .aluop(aluop),   //ALU OP Directly Assigned
      .neg(LEDR[0]),      //Show Neg Flag
      .overflow(LEDR[1]), //Show V Flag
      .zero(LEDR[2]),     //Show 0 Flag
      .result(result)     //See HEX displays below
    );


// ALUOP
assign aluop = aluop_t'(~KEY[3:0]);

// Inputs A
assign A = {16'{SW[16]},SW[15:0]};

//Store values for B
always_ff @(posedge SW[17]) begin
  B <= A;
end

//  HEX Displays
      //HEX0
  always_comb
  begin
    unique casez (result[3:0])
      'h0: HEX0 = 7'b1000000;
      'h1: HEX0 = 7'b1111001;
      'h2: HEX0 = 7'b0100100;
      'h3: HEX0 = 7'b0110000;
      'h4: HEX0 = 7'b0011001;
      'h5: HEX0 = 7'b0010010;
      'h6: HEX0 = 7'b0000010;
      'h7: HEX0 = 7'b1111000;
      'h8: HEX0 = 7'b0000000;
      'h9: HEX0 = 7'b0010000;
      'ha: HEX0 = 7'b0001000;
      'hb: HEX0 = 7'b0000011;
      'hc: HEX0 = 7'b0100111;
      'hd: HEX0 = 7'b0100001;
      'he: HEX0 = 7'b0000110;
      'hf: HEX0 = 7'b0001110;
    endcase
  end

      //HEX1
  always_comb
  begin
    unique casez (result[7:4])
      'h0: HEX1 = 7'b1000000;
      'h1: HEX1 = 7'b1111001;
      'h2: HEX1 = 7'b0100100;
      'h3: HEX1 = 7'b0110000;
      'h4: HEX1 = 7'b0011001;
      'h5: HEX1 = 7'b0010010;
      'h6: HEX1 = 7'b0000010;
      'h7: HEX1 = 7'b1111000;
      'h8: HEX1 = 7'b0000000;
      'h9: HEX1 = 7'b0010000;
      'ha: HEX1 = 7'b0001000;
      'hb: HEX1 = 7'b0000011;
      'hc: HEX1 = 7'b0100111;
      'hd: HEX1 = 7'b0100001;
      'he: HEX1 = 7'b0000110;
      'hf: HEX1 = 7'b0001110;
    endcase
  end

      //HEX2
  always_comb
  begin
    unique casez (result[11:8])
      'h0: HEX2 = 7'b1000000;
      'h1: HEX2 = 7'b1111001;
      'h2: HEX2 = 7'b0100100;
      'h3: HEX2 = 7'b0110000;
      'h4: HEX2 = 7'b0011001;
      'h5: HEX2 = 7'b0010010;
      'h6: HEX2 = 7'b0000010;
      'h7: HEX2 = 7'b1111000;
      'h8: HEX2 = 7'b0000000;
      'h9: HEX2 = 7'b0010000;
      'ha: HEX2 = 7'b0001000;
      'hb: HEX2 = 7'b0000011;
      'hc: HEX2 = 7'b0100111;
      'hd: HEX2 = 7'b0100001;
      'he: HEX2 = 7'b0000110;
      'hf: HEX2 = 7'b0001110;
    endcase
  end

      //HEX3
  always_comb
  begin
    unique casez (result[15:12])
      'h0: HEX3 = 7'b1000000;
      'h1: HEX3 = 7'b1111001;
      'h2: HEX3 = 7'b0100100;
      'h3: HEX3 = 7'b0110000;
      'h4: HEX3 = 7'b0011001;
      'h5: HEX3 = 7'b0010010;
      'h6: HEX3 = 7'b0000010;
      'h7: HEX3 = 7'b1111000;
      'h8: HEX3 = 7'b0000000;
      'h9: HEX3 = 7'b0010000;
      'ha: HEX3 = 7'b0001000;
      'hb: HEX3 = 7'b0000011;
      'hc: HEX3 = 7'b0100111;
      'hd: HEX3 = 7'b0100001;
      'he: HEX3 = 7'b0000110;
      'hf: HEX3 = 7'b0001110;
    endcase
  end

      //HEX4
  always_comb
  begin
    unique casez (result[19:16])
      'h0: HEX4 = 7'b1000000;
      'h1: HEX4 = 7'b1111001;
      'h2: HEX4 = 7'b0100100;
      'h3: HEX4 = 7'b0110000;
      'h4: HEX4 = 7'b0011001;
      'h5: HEX4 = 7'b0010010;
      'h6: HEX4 = 7'b0000010;
      'h7: HEX4 = 7'b1111000;
      'h8: HEX4 = 7'b0000000;
      'h9: HEX4 = 7'b0010000;
      'ha: HEX4 = 7'b0001000;
      'hb: HEX4 = 7'b0000011;
      'hc: HEX4 = 7'b0100111;
      'hd: HEX4 = 7'b0100001;
      'he: HEX4 = 7'b0000110;
      'hf: HEX4 = 7'b0001110;
    endcase
  end

      //HEX5
  always_comb
  begin
    unique casez (result[23:20])
      'h0: HEX5 = 7'b1000000;
      'h1: HEX5 = 7'b1111001;
      'h2: HEX5 = 7'b0100100;
      'h3: HEX5 = 7'b0110000;
      'h4: HEX5 = 7'b0011001;
      'h5: HEX5 = 7'b0010010;
      'h6: HEX5 = 7'b0000010;
      'h7: HEX5 = 7'b1111000;
      'h8: HEX5 = 7'b0000000;
      'h9: HEX5 = 7'b0010000;
      'ha: HEX5 = 7'b0001000;
      'hb: HEX5 = 7'b0000011;
      'hc: HEX5 = 7'b0100111;
      'hd: HEX5 = 7'b0100001;
      'he: HEX5 = 7'b0000110;
      'hf: HEX5 = 7'b0001110;
    endcase
  end

      //HEX6
  always_comb
  begin
    unique casez (result[27:24])
      'h0: HEX6 = 7'b1000000;
      'h1: HEX6 = 7'b1111001;
      'h2: HEX6 = 7'b0100100;
      'h3: HEX6 = 7'b0110000;
      'h4: HEX6 = 7'b0011001;
      'h5: HEX6 = 7'b0010010;
      'h6: HEX6 = 7'b0000010;
      'h7: HEX6 = 7'b1111000;
      'h8: HEX6 = 7'b0000000;
      'h9: HEX6 = 7'b0010000;
      'ha: HEX6 = 7'b0001000;
      'hb: HEX6 = 7'b0000011;
      'hc: HEX6 = 7'b0100111;
      'hd: HEX6 = 7'b0100001;
      'he: HEX6 = 7'b0000110;
      'hf: HEX6 = 7'b0001110;
    endcase
  end

      //HEX7
  always_comb
  begin
    unique casez (result[31:28])
      'h0: HEX7 = 7'b1000000;
      'h1: HEX7 = 7'b1111001;
      'h2: HEX7 = 7'b0100100;
      'h3: HEX7 = 7'b0110000;
      'h4: HEX7 = 7'b0011001;
      'h5: HEX7 = 7'b0010010;
      'h6: HEX7 = 7'b0000010;
      'h7: HEX7 = 7'b1111000;
      'h8: HEX7 = 7'b0000000;
      'h9: HEX7 = 7'b0010000;
      'ha: HEX7 = 7'b0001000;
      'hb: HEX7 = 7'b0000011;
      'hc: HEX7 = 7'b0100111;
      'hd: HEX7 = 7'b0100001;
      'he: HEX7 = 7'b0000110;
      'hf: HEX7 = 7'b0001110;
    endcase
  end

endmodule
