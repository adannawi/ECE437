`include "decode_if.vh"
`include "cpu_types_pkg.vh"

module decode_registers (
  input CLK, nRST,
  decode_if.de dif
);

always_ff @ (posedge CLK, negedge nRST)
begin
  if (!nRST) begin //Note these were originall (mistakenly?) assigning a value to the IN signals
    dif.PCIncOUT <= 0;
    dif.InstructionOUT <= 0;
    dif.writeRegOUT <= 0;
    dif.MemtoRegOUT <= 0;
    dif.RWDSelOUT <= 0;
    dif.dWENOUT <= 0;
    dif.dRENOUT <= 0;
    dif.PCSrcOUT <= 0;
    dif.RegDstOUT <= 0;
    dif.ALUSrcOUT <= 0;
    dif.aluopOUT <= ALU_SLL;
    dif.ext_datOUT <= 0;
    dif.busAOUT <= 0;
    dif.busBOUT <= 0;
    dif.RtOUT <= 0;
    dif.RdOUT <= 0;
  end else if (dif.flush) begin //Note these were originall (mistakenly?) assigning a value to the IN signals
    dif.PCIncOUT <= 0;
    dif.InstructionOUT <= 0;
    dif.writeRegOUT <= 0;
    dif.MemtoRegOUT <= 0;
    dif.RWDSelOUT <= 0;
    dif.dWENOUT <= 0;
    dif.dRENOUT <= 0;
    dif.PCSrcOUT <= 0;
    dif.RegDstOUT <= 0;
    dif.ALUSrcOUT <= 0;
    dif.aluopOUT <= ALU_SLL;
    dif.ext_datOUT <= 0;
    dif.busAOUT <= 0;
    dif.busBOUT <= 0;
    dif.RtOUT <= 0;
    dif.RdOUT <= 0;
  end else if (dif.enable) begin
    dif.PCIncOUT <= dif.PCIncIN;
    dif.InstructionOUT <= dif.InstructionIN;
    dif.writeRegOUT <= dif.writeRegIN;
    dif.MemtoRegOUT <= dif.MemtoRegIN;
    dif.RWDSelOUT <= dif.RWDSelIN;
    dif.dWENOUT <= dif.dWENIN;
    dif.dRENOUT <= dif.dRENIN;
    dif.PCSrcOUT <= dif.PCSrcIN;
    dif.RegDstOUT <= dif.RegDstIN;
    dif.ALUSrcOUT <= dif.ALUSrcIN;
    dif.aluopOUT <= dif.aluopIN;
    dif.ext_datOUT <= dif.ext_datIN;
    dif.busAOUT <= dif.busAIN;
    dif.busBOUT <= dif.busBIN;
    dif.RtOUT <= dif.RtIN;
    dif.RdOUT <= dif.RdIN;
  end else begin
    dif.PCIncOUT <= dif.PCIncOUT;
    dif.InstructionOUT <= dif.InstructionOUT;
    dif.writeRegOUT <= dif.writeRegOUT;
    dif.MemtoRegOUT <= dif.MemtoRegOUT;
    dif.RWDSelOUT <= dif.RWDSelOUT;
    dif.dWENOUT <= dif.dWENOUT;
    dif.dRENOUT <= dif.dRENOUT;
    dif.PCSrcOUT <= dif.PCSrcOUT;
    dif.RegDstOUT <= dif.RegDstOUT;
    dif.ALUSrcOUT <= dif.ALUSrcOUT;
    dif.aluopOUT <= dif.aluopOUT;
    dif.ext_datOUT <= dif.ext_datOUT;
    dif.busAOUT <= dif.busAOUT;
    dif.busBOUT <= dif.busBOUT;
    dif.RtOUT <= dif.RtOUT;
    dif.RdOUT <= dif.RdOUT;

  end
end

endmodule
