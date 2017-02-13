/*
 85                 end else begin

    Author: Noah Petersen
    Description: ALU made as part of Lab 1 for ECE 43700
*/
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module alu (
    input logic signed [31:0] A,
    input logic signed [31:0] B,
    input aluop_t aluop,
    output logic neg,
    output logic overflow,
    output logic zero,
    output logic signed [31:0] result
    );

//Variables
logic [31:0] uA; //Unsigned A & B
logic [31:0] uB;

assign uA = A;
assign uB = B;
/*
  Operations to support:
  -Logical Shift Left/Right (2)
  -AND (1)
  -OR (1)
  -XOR (1)
  -NOR (1)
  -Signed Add (1)
  -Signed Sutract (1)
  -Set less than signed (1)
  -Set less than unsigned (1
    10 total Ops, 4 bits/16 Selections for Ops)
*/

//Zero Flag
always_comb begin
  if(result == 32'h00000000) begin
    zero = 1'b1;
  end else begin
    zero = 1'b0;
  end
end

//Negative Flag easy to set
// Is this only set for certain operations?
assign neg = result[31];

//Overflow Flag
//Is there an easier way to do this?
always_comb begin

  //Addition Overflow Cases
  if(aluop == ALU_ADD) begin
    if((A[31] == B[31]) && (result[31] != A[31])) begin
      overflow = 1;
    end else begin
      overflow = 0;
    end

  //Subtraction Overflow Cases
  end else if (aluop == ALU_SUB) begin
    if((A[31] ^ B[31]) && (result[31] == B[31])) begin
      overflow = 1;
    end else begin
      overflow = 0;
    end

  //No other conditions met, need to just output an arbitrary value
  end else begin
    overflow = 0;
  end
end

//logic carry;

//Result Calculation
always_comb begin
  //carry = 0; //Set default value
  casez(aluop)
    ALU_SLL:  result = A << B; //Does it make sense for this to be able to shift more than 32 bits?
    ALU_SRL:  result = A >> B; // See comment above ^^^
    ALU_ADD:  result = A + B; //result = 'signed(A) + 'signed(B)
    ALU_SUB:  result = A - B; //result = 'signed(A) - 'signed(B)
    ALU_AND:  result = A & B;
    ALU_OR:   result = A | B;
    ALU_XOR:  result = A ^ B;
    ALU_NOR:  result = ~(A | B);
    ALU_SLT:  if($signed(A) < $signed(B)) begin //if('signed(A) < 'signed(B)) begin
                result = 1;
              end else begin
                result = 0;
              end
    ALU_SLTU: if(uA < uB) begin
                result = 1;
              end else begin
                result = 0;
              end
    //If A < B (unsigned), set output to 1, else 0.
    default: result = 32'hECE43700; //Make same as one operation just in case since not everything is defined
  endcase
end
endmodule
