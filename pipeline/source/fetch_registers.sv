`include "fetch_if.vh"
`include "cpu_types_pkg.vh"

module fetch_registers (
  input logic CLK, nRST,
  ifetch_if.fi fif
);

always_ff @ (posedge CLK, negedge nRST)
begin
  if (!nRST) begin
    fif.PCIncOUT <= 0;
    fif.InstructionOUT <= 0;
  end else if (fif.flush) begin
    fif.PCIncOUT <= 0;
    fif.InstructionOUT <= 0;
  end else if (fif.enable)begin
    fif.PCIncOUT <= fif.PCIncIN;
    fif.InstructionOUT <= fif.InstructionIN;
  end else begin
    fif.PCIncOUT <= fif.PCIncOUT;
    fif.InstructionOUT <= fif.InstructionOUT;
  end
end

endmodule
