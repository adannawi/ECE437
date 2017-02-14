`include "mem_if.vh"
`include "cpu_types_pkg.vh"

module mem_registers (
  input logic CLK, nRST,
  mem_if.my mif
);

always_ff @ (posedge CLK, negedge nRST)
begin
  if (!nRST) begin
    mif.PCIncOUT <= 0;
    mif.writeRegOUT <= 0;
    mif.MemtoRegOUT <= 0;
    mif.RegWDSelOUT <= 0;
    mif.opcodeOUT <= RTYPE;
    mif.dmemloadOUT <= 0;
    mif.resultOUT <= 0;
    mif.rwOUT <= 0;
  end else if (mif.flush) begin
    mif.PCIncOUT <= 0;
    mif.writeRegOUT <= 0;
    mif.MemtoRegOUT <= 0;
    mif.RegWDSelOUT <= 0;
    mif.opcodeOUT <= RTYPE;
    mif.dmemloadOUT <= 0;
    mif.resultOUT <= 0;
    mif.rwOUT <= 0;
  end else if (mif.enable) begin
    mif.PCIncOUT <= mif.PCIncIN;
    mif.writeRegOUT <= mif.writeRegIN;
    mif.MemtoRegOUT <= mif.MemtoRegIN;
    mif.RegWDSelOUT <= mif.RegWDSelIN;
    mif.opcodeOUT <= mif.opcodeIN;
    mif.dmemloadOUT <= mif.dmemloadIN;
    mif.resultOUT <= mif.resultIN;
    mif.rwOUT <= mif.rwIN;
  end else begin
    mif.PCIncOUT <= mif.PCIncOUT;
    mif.writeRegOUT <= mif.writeRegOUT;
    mif.MemtoRegOUT <= mif.MemtoRegOUT;
    mif.RegWDSelOUT <= mif.RegWDSelOUT;
    mif.opcodeOUT <= mif.opcodeOUT;
    mif.dmemloadOUT <= mif.dmemloadOUT;
    mif.resultOUT <= mif.resultOUT;
    mif.rwOUT <= mif.rwOUT;
  end
end

endmodule
