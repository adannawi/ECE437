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
    eif.RegWDSelOUT <= 0;
    eif.dWENOUT <= 0;
    eif.dRENOUT <= 0;
    eif.opcodeOUT <= RTYPE;
    eif.resultOUT <= 0;
    eif.busBOUT <= 0;
    eif.rwOUT <= 0;
  end else if (eif.flush) begin
    eif.PCIncOUT <= 0;
    eif.writeRegOUT <= 0;
    eif.MemtoRegOUT <= 0;
    eif.RegWDSelOUT <= 0;
    eif.dWENOUT <= 0;
    eif.dRENOUT <= 0;
    eif.opcodeOUT <= RTYPE;
    eif.resultOUT <= 0;
    eif.rwOUT <= 0;
    eif.busBOUT <= 0;
  end else if (eif.enable) begin
    eif.PCIncOUT <= eif.PCIncIN;
    eif.writeRegOUT <= eif.writeRegIN;
    eif.MemtoRegOUT <= eif.MemtoRegIN;
    eif.RegWDSelOUT <= eif.RegWDSelIN;
    eif.dWENOUT <= eif.dWENIN;
    eif.dRENOUT <= eif.dRENIN;
    eif.opcodeOUT <= eif.opcodeIN;
    eif.resultOUT <= eif.resultIN;
    eif.rwOUT <= eif.rwIN;
    eif.busBOUT <= eif.busBIN;
  end else begin
    eif.PCIncOUT <= eif.PCIncOUT;
    eif.writeRegOUT <= eif.writeRegOUT;
    eif.MemtoRegOUT <= eif.MemtoRegOUT;
    eif.RegWDSelOUT <= eif.RegWDSelOUT;
    eif.dWENOUT <= eif.dWENOUT;
    eif.dRENOUT <= eif.dRENOUT;
    eif.opcodeOUT <= eif.opcodeOUT;
    eif.resultOUT <= eif.resultOUT;
    eif.rwOUT <= eif.rwOUT;
    eif.busBOUT <= eif.busBOUT;
  end
end

endmodule
