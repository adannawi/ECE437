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
    dif.RegWDSelOUT <= 0;
    dif.dWENOUT <= 0;
    dif.dRENOUT <= 0;
    dif.PCSrcOUT <= 0;
    dif.RegDstOUT <= 0;
    dif.ALUSrcOUT <= 0;
    dif.aluopOUT <= ALU_SLL;
    dif.Ext_datOUT <= 0;
    dif.busAOUT <= 0;
    dif.busBOUT <= 0;
    dif.rtOUT <= 0;
    dif.rdOUT <= 0;
    dif.rsOUT <= 0;
    dif.opcodeOUT <= RTYPE;
  end else if (dif.flush) begin //Note these were originall (mistakenly?) assigning a value to the IN signals
    dif.PCIncOUT <= 0;
    dif.InstructionOUT <= 0;
    dif.writeRegOUT <= 0;
    dif.MemtoRegOUT <= 0;
    dif.RegWDSelOUT <= 0;
    dif.dWENOUT <= 0;
    dif.dRENOUT <= 0;
    dif.PCSrcOUT <= 0;
    dif.RegDstOUT <= 0;
    dif.ALUSrcOUT <= 0;
    dif.aluopOUT <= ALU_SLL;
    dif.Ext_datOUT <= 0;
    dif.busAOUT <= 0;
    dif.busBOUT <= 0;
    dif.rtOUT <= 0;
    dif.rdOUT <= 0;
    dif.rsOUT <= 0;
    dif.opcodeOUT <= RTYPE;
  end else if (dif.enable) begin
    dif.PCIncOUT <= dif.PCIncIN;
    dif.InstructionOUT <= dif.InstructionIN;
    dif.writeRegOUT <= dif.writeRegIN;
    dif.MemtoRegOUT <= dif.MemtoRegIN;
    dif.RegWDSelOUT <= dif.RegWDSelIN;
    dif.dWENOUT <= dif.dWENIN;
    dif.dRENOUT <= dif.dRENIN;
    dif.PCSrcOUT <= dif.PCSrcIN;
    dif.RegDstOUT <= dif.RegDstIN;
    dif.ALUSrcOUT <= dif.ALUSrcIN;
    dif.aluopOUT <= dif.aluopIN;
    dif.Ext_datOUT <= dif.Ext_datIN;
    dif.busAOUT <= dif.busAIN;
    dif.busBOUT <= dif.busBIN;
    dif.rtOUT <= dif.rtIN;
    dif.rdOUT <= dif.rdIN;
    dif.rsOUT <= dif.rsIN;
    dif.opcodeOUT <= dif.opcodeIN;
  end else begin
    dif.PCIncOUT <= dif.PCIncOUT;
    dif.InstructionOUT <= dif.InstructionOUT;
    dif.writeRegOUT <= dif.writeRegOUT;
    dif.MemtoRegOUT <= dif.MemtoRegOUT;
    dif.RegWDSelOUT <= dif.RegWDSelOUT;
    dif.dWENOUT <= dif.dWENOUT;
    dif.dRENOUT <= dif.dRENOUT;
    dif.PCSrcOUT <= dif.PCSrcOUT;
    dif.RegDstOUT <= dif.RegDstOUT;
    dif.ALUSrcOUT <= dif.ALUSrcOUT;
    dif.aluopOUT <= dif.aluopOUT;
    dif.Ext_datOUT <= dif.Ext_datOUT;
    dif.busAOUT <= dif.busAOUT;
    dif.busBOUT <= dif.busBOUT;
    dif.rtOUT <= dif.rtOUT;
    dif.rdOUT <= dif.rdOUT;
    dif.rsOUT <= dif.rsOUT;
    dif.opcodeOUT <= dif.opcodeOUT;
  end
end

endmodule
