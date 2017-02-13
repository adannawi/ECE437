/*
  Noah Petersen
  peter248

  ALU test bench
*/
import cpu_types_pkg::*;

//Mapped Timing
`timescale 1 ns / 1 ns


module alu_tb;
/* Clock not needed here
  //Clock Definition
  parameter PERIOD = 10; //10ns Period
  logic CLK = 0;

  always #(PERIOD/2) CLK++;
*/
  //ALU Variables
  logic [31:0] A;
  logic [31:0] B;
  aluop_t aluop;
  logic neg;
  logic overflow;
  logic zero;
  logic [31:0] result;

  //Other Variables
  int testcase;

  // Test Program
  test_alu PROG (
    //ALU variables
    .A(A),
    .B(B),
    .aluop(aluop),
    .neg(neg),
    .overflow(overflow),
    .zero(zero),
    .result(result),
     //Testcase
    .testcase(testcase)
  );

  //DUT -> Here these could be the same since no interface is used
`ifndef MAPPED
  //Source Declaration -> Can use interfaces without issues
  alu DUT(
      .A(A),
      .B(B),
      .aluop(aluop),
      .neg(neg),
      .overflow(overflow),
      .zero(zero),
      .result(result)
     ); //Add Other signals
`else
  //Mapped Declaration -> Need to breakout interface if using synthesized
  //version
  alu DUT(
      .A(A),
      .B(B),
      .aluop(aluop),
      .neg(neg),
      .overflow(overflow),
      .zero(zero),
      .result(result)
     ); //Add Other signals

`endif
endmodule


program test_alu
(
  //alu signals
  input logic [31:0]result,
  input logic neg,
  input logic overflow,
  input logic zero,

  output logic [31:0] A,
  output logic [31:0] B,
  output aluop_t aluop,
  output int testcase
);

  initial begin
    testcase = 0;
    A = 0;
    B = 0;
    aluop = ALU_SLL;

/* ALU Opcodes -> Append "ALU_" to opcode name to use
  SLL   0000
  SRL   0001
  ADD   0010
  SUB   0011
  AND   0100
  OR    0101
  XOR   0111
  NOR   1001
  SLT   1010
  SLTU  1011
*/

    //TestCase Set 1: Shifts
    newtestcase();
    //1 Check Left
    Send_Vector(ALU_SLL,32'h00000001,32'h00000004);
    Check_Output(32'h00000010,0,0,0);

    //2 Check Right
    newtestcase();
    Send_Vector(ALU_SRL,32'h10000000,32'h00000004);
    Check_Output(32'h01000000,0,0,0);


    //Testcase Set  2: ADD, including overflow, positives and negatives (since signed)


    // 3 Basic Add w/ positive
    newtestcase();
    Send_Vector(ALU_ADD,32'h01010101 ,32'h00101010);
    Check_Output(32'h01111111,0,0,0);

    // 4  Basic Add w/ negative
    newtestcase();
    Send_Vector(ALU_ADD,32'h81010101,32'h80101010);
    Check_Output(32'h81111111,1,0,0);

    //  5 Postive Overflow
    newtestcase();
    Send_Vector(ALU_ADD,32'h7FFFFFFF,32'h00000002);
    Check_Output(32'h10000001,1,1,0);

    //  6 Negative Overflow
    newtestcase();
    Send_Vector(ALU_ADD,32'hFFFFFFFF,32'h80000002);
    Check_Output(32'h01000000,0,0,0);


    //Testcase Set 3: SUB, including overflow, postives and negatives

    // 7 Basic Sub W/Positive
    newtestcase();
    Send_Vector(ALU_SUB,32'h0FFFFFFF ,32'h0FFF0000);
    Check_Output(32'h01111111,0,0,0); //Values not set
    // 8  Basic Sub w/ Neg
    newtestcase();
    Send_Vector(ALU_SUB,32'h8FFFFFFF,32'h8000FFFF);
    Check_Output(32'h81111111,1,0,0); //Not Set

    // 9  Postive A Overflow
    newtestcase();
    Send_Vector(ALU_SUB,32'h7FFFFFFF,32'h80000002);
    Check_Output(32'h10000001,1,1,0); //Not Set

    //  10 Negative A Overflow
    newtestcase();
    Send_Vector(ALU_SUB,32'hFFFFFFFF,32'h00000002);
    Check_Output(32'h01000000,0,0,0); //Not Set

    // 11 AND Testing
    newtestcase();
    Send_Vector(ALU_AND,32'h55AAFF00,32'hAA55FF00);
    Check_Output(32'hF0F0F0F0,0,0,0); //Not Set

    // 12 OR Testing
    newtestcase();
    Send_Vector(ALU_OR,32'hAA55FF00,32'h55AAFF00);
    Check_Output(32'hFFFFFFFF,0,0,0); //Not Set

    // 13 XOR Testing
    newtestcase();
    Send_Vector(ALU_XOR,32'hFFFFAAAA,32'hFFFF5555);
    Check_Output(32'h0000FFFF,0,0,0); //Not Set

    // 14 NOR Testing
    newtestcase();
    Send_Vector(ALU_NOR,32'hAA55FF00,32'h55AAFF00);
    Check_Output(32'h000000FF,0,0,0); //Not Set

    // 15 SLT (Signed)  Testing
    //    -1 < 1
    newtestcase();
    Send_Vector(ALU_SLT,32'h80000001,32'h00000001);
    Check_Output(32'h00000001,0,0,0); //Not Set

    // 16   1 > -1
    newtestcase();
    Send_Vector(ALU_SLT,32'h00000001,32'h80000001);
    Check_Output(32'h00000001,0,0,0); //Not Set

    // 17    1 < 2
    newtestcase();
    Send_Vector(ALU_SLT,32'h00000001,32'h00000002);
    Check_Output(32'h00000001,0,0,0); //Not Set

    // 18   -2 < -1 Why is this failing?
    newtestcase();
    Send_Vector(ALU_SLT,32'hFFFFFFFF,32'hF0000001);
    Check_Output(32'h00000001,0,0,0); //Not Set

    // 19 SLTU Testing

    //  Very large > 1 (Check that not read as negetive)
    newtestcase();
    Send_Vector(ALU_SLTU,32'h80000001,32'h00000001);
    Check_Output(32'h00000000,0,0,0); //Not Seti

    // 20  1 < 2 Basic Case
    newtestcase();
    Send_Vector(ALU_SLTU,32'h00000001,32'h00000002);
    Check_Output(32'h00000001,0,0,0); //Not Seti
    //More test Cases...
  end

  //Tasks
  task Send_Vector (
      input aluop_t op,
      input [31:0] data_A,
      input [31:0] data_B
    );
    begin
      aluop = op;
      A = data_A;
      B = data_B;
    end
  endtask

  //Check output of function
  //Flag Order: Neg, Overflow, Zero
  task Check_Output (
      input [31:0] expected,
      input exp_neg,
      input exp_overflow,
      input exp_zero
    );
    begin
      #(10);
      //Check result
      if(expected != result) begin
        $error("Expected value incorrect in testcase: %d", testcase);
      end
      //Check Neg flag
      if(neg != exp_neg) begin
        $error("Neg flag incorrect in testcase: %d", testcase);
      end
      //Check zero
      if(zero != exp_zero) begin
        $error("Neg flag incorrect in testcase: %d", testcase);
      end
      //Check overflow
      if(overflow != exp_overflow) begin
        $error("Neg flag incorrect in testcase: %d", testcase);
      end

      #(10);
      //Reset values of inputs
      aluop = ALU_SLL;
      A = 0;
      B = 0;
    end
  endtask

  //New Testcase
  task newtestcase;
    begin
      testcase += 1;
      $info("Running Testcase number %d",testcase);
       #(10);
    end
  endtask

endprogram
