`include "exec_if.vh"
`include "cpu_types_pkg.vh"

module exec_registers (
  input logic CLK, nRST,
  exec_if.ex eif
);

always_ff @ (posedge CLK, negedge nRST)
begin
  if (!nRST) begin
    eif.PCIncOUT <= 0;
    eif.writeRegOUT <= 0;
    eif.MemtoRegOUT <= 0;
    eif.RWDSelOUT <= 0;
    eif.dWENOUT <= 0;
    eif.dRENOUT <= 0;
    eif.opcodeOUT <= 0;
    eif.branchaddrOUT <= 0;
    eif.resultOUT <= 0;
    eif.rwOUT <= 0;
    eif.busBOUT <= 0;
    eid.InstructionOUT <= 0;
  end else if (eif.flush) begin
    eif.PCIncOUT <= 0;
    eif.writeRegOUT <= 0;
    eif.MemtoRegOUT <= 0;
    eif.RWDSelOUT <= 0;
    eif.dWENOUT <= 0;
    eif.dRENOUT <= 0;
    eif.opcodeOUT <= 0;
    eif.branchaddrOUT <= 0;
    eif.resultOUT <= 0;
    eif.rwOUT <= 0;
    eif.busBOUT <= 0;
    eid.InstructionOUT <= 0;
  end else if (eif.enable) begin
    eif.PCIncOUT <= eif.PCIncIN;
    eif.writeRegOUT <= eif.writeRegIN;
    eif.MemtoRegOUT <= eif.MemtoRegIN;
    eif.RWDSelOUT <= eif.RWDSelIN;
    eif.dWENOUT <= eif.dWENIN;
    eif.dRENOUT <= eif.dRENIN;
    eif.opcodeOUT <= eif.opcodeIN;
    eif.branchaddrOUT <= eif.branchaddrIN;
    eif.resultOUT <= eif.resultIN;
    eif.rwOUT <= eif.rwIN;
    eif.busBOUT <= eif.busBIN;
    eid.InstructionOUT <= eid.InstructionIN;
  end else begin
    eif.PCIncOUT <= eif.PCIncOUT;
    eif.writeRegOUT <= eif.writeRegOUT;
    eif.MemtoRegOUT <= eif.MemtoRegOUT;
    eif.RWDSelOUT <= eif.RWDSelOUT;
    eif.dWENOUT <= eif.dWENOUT;
    eif.dRENOUT <= eif.dRENOUT;
    eif.opcodeOUT <= eif.opcodeOUT;
    eif.branchaddrOUT <= eif.branchaddrOUT;
    eif.resultOUT <= eif.resultOUT;
    eif.rwOUT <= eif.rwOUT;
    eif.busBOUT <= eif.busBOUT;
    eid.InstructionOUT <= eid.InstructionOUT;
  end
end

endmodule
