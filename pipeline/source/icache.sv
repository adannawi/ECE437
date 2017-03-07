`include "caches_if.vh"
`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
`include "datapath_cache_if.vh"

module icache (
	input CLK, nRST,
	caches_if.icache icif,
	datapath_cache_if dcif,
	cache_control_if ccif
	);

import cpu_types_pkg::*;

// Struct representing data in a set //
typedef struct packed {
	logic valid;
	logic [ITAG_W-1:0] tag;
	word_t value;
} icset;

icset[15:0] isets;
icachef_t icache;
integer i;

always_ff @ (posedge CLK, negedge nRST)
begin
	if (!nRST) begin
		for (i = 0; i < 16; i++) begin // Reset all 16 sets
			isets[i].valid <= 0;
			isets[i].tag <= 0;
			isets[i].value <= 0;
		end
	end else begin
		if (dcif.imemREN && !ccif.iwait) begin
			isets[icache.idx].valid <= 1;
			isets[icache.idx].tag <= icache.tag;
			isets[icache.idx].value <= ccif.iload;
		end
	end
end

assign icache = icachef_t'(dcif.imemaddr)
// Hit Logic //
assign dcif.hit = (isets[icache.idx].valid && (isets[icache.idx].tag == icache.tag)) && dcif.imemREN;
assign dcif.imemload = isets[icache.idx].value;
// ccif.iREN
// ccif.iaddr

endmodule