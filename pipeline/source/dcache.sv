`include "caches_if.vh"
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"

module dcache (
	input CLK, nRST,
	datapath_cache_if.dcache dcif,
	caches_if.dcache cif
	);

	typedef struct packed {
		logic valid;
		logic dirty;
		logic [ITAG_W-1:0] tag;
		word_t block1;
		word_t block2;
	 dway;

	typedef struct packed {
		dway way1
		dway way2
	} dset;

	//State Enumeration
	typedef enum logic [3:0]{
    	IDLE     	= 4'b0001,
    	WB1    		= 4'b0010,
    	WB2     	= 4'b0011,
    	FD1     	= 4'b0100,
    	FD2     	= 4'b0101,
    	WBD1     	= 4'b0110,
    	WBD2     	= 4'b0111,
    	DCHC     	= 4'b1000,
    	INVAL    	= 4'b1001,
    	WRCNT     	= 4'b1010,
    	FLUSH     	= 4'b1011
	} Statetype;

	//Local Variables
	Statetype state;
	Statetype next_state;

	dset[0:7] dsets;
	dcachef_t dcache;
	integer i;
	logic miss;

	// State Machine Output variables
	logic [15:0] clean; //Resets to dirty bits on read from mem


	//Write Enables
	logic [15:0] cWEN;

	logic [15:0] LRU;


	assign dcache = dcachef_t'(dcif.imemaddr);
  //	This is where inputs from datapath come from
  // datapath cache if dcache ports
  //modport dcache (
  //  input   halt, dmemREN, dmemWEN,
  //          datomic, dmemstore, dmemaddr,
  //  output  dhit, dmemload, flushed
  //);

  // dcache ports to controller
  //modport dcache (
  //input   dwait, dload,
  //        ccwait, ccinv, ccsnoopaddr,
  //output  dREN, dWEN, daddr, dstore,
  //        ccwrite, cctrans
  //);

assign dcif.dhit = (dcif.dmemWEN || dcif.dmemREN) &&((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1))  || ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1));

//	Register Sets
always_ff @ (posedge CLK, negedge nRST)
begin
	if (!nRST) begin
		for (i = 0; i < 8; i++) begin // Reset all 16 sets
			dsets[i].way1.valid <= 0;
			dsets[i].way1.dirty <= 0;
			dsets[i].way1.tag <= 0;
			dsets[i].way1.block1 <= 0;
			dsets[i].way1.block2 <= 0;
			dsets[i].way2.valid <= 0;
			dsets[i].way2.dirty <= 0;
			dsets[i].way2.tag <= 0;
			dsets[i].way2.block1 <= 0;
			dsets[i].way2.block2 <= 0;
		end
	end else begin
		//Write on hit

		//Parse through sets
		for (i = 0; i < 8; i++) begin 
			//Check each way in set
			if (cWEN[i*2]) begin
				dsets[i].way1.valid <= 1;
				dsets[i].way1.dirty <= !clean;
				dsets[i].way1.tag <= dcache.tag;

			//Block Selection

				//On hit/write
				if (dhit && !memtocache) begin
					//Base write location on incoming mem request
					if (dcache.blkoff == 0) begin
						dsets[i].way1.block1 <= block_data;
					end else begin
						dsets[i].way1.block2 <= block_data;
					end
				end else if (memtocache) begin
					//Base off state generated block_sel, memtocache will only be asserted 
					if (dcache.blkoff == 0) begin
						dsets[i].way1.block1 <= block_data;
					end else begin
						dsets[i].way1.block2 <= block_data;
					end
				end
			end else if (cWEN[i*2 + 1] == 1) begin
				dsets[i].way2.valid <= 1;
				dsets[i].way2.dirty <= !clean;
				dsets[i].way2.tag <= dcache.tag;

				//Block Selection

				//On hit/write
				if (dhit && !memtocache) begin
					//Base write location on incoming mem request
					if (dcache.blkoff == 0) begin
						dsets[i].way2.block1 <= block_data;
					end else begin
						dsets[i].way2.block2 <= block_data;
					end
				end else if (memtocache) begin
					//Base off state generated block_sel, memtocache will only be asserted 
					if (dcache.blkoff == 0) begin
						dsets[i].way2.block1 <= block_data;
					end else begin
						dsets[i].way2.block2 <= block_data;
					end
				end
			end else begin
				//Defaults if no reset, no cWEN
				dsets[i].way1.valid <= dsets[i].way1.valid;
				dsets[i].way1.dirty <= dsets[i].way1.dirty;
				dsets[i].way1.tag <= dsets[i].way1.tag;
				dsets[i].way1.block1 <= dsets[i].way1.block1;
				dsets[i].way1.block2 <= dsets[i].way1.block2;
				dsets[i].way2.valid <= dsets[i].way2.valid;
				dsets[i].way2.dirty <= dsets[i].way2.dirty;
				dsets[i].way2.tag <= dsets[i].way2.tag;
				dsets[i].way2.block1 <= dsets[i].way2.block1;
				dsets[i].way2.block2 <= dsets[i].way2.block2;
			end
		end
	end
end

//Cache data read logic


//Cache Write Enable logic
always_comb begin
	cWEN = '0;

	//Write on hit, if not writing back from memory to cache block
	if (dhit && dcif.dmemWEN && !memtocache) begin
		//Enable whichever index has the matching tag, & block
		//Indexes 000 to 111
		if (dsets[dcache.idx].way1.tag == dcache.tag) begin
			cWEN[dcache.idx * 2] = 1;
		end else  begin
		//Will not have a hit if this second one matches, so can use an else
			cWEN[dcache.idx * 2 + 1] = 1;
		end
	end else if ((state == FD1) && !cif.dwait) begin

	end else if ((state == FD2) && !cif.dwait) begin

	//Write on fetch data
	//Only enable write on !dwait
	//Select way baased on LRU
end

word_t block_data;
	//Block write data selection logic
always_comb begin
	if(memtocache) begin
		//Write to block indicated by state machine, enable only 
		block_data = cif.dload;
	end else begin
		//Else write just to what's indicated by block offset
		block_data = dcif.dmemstore
	end
end


//Block selection data logic
always_comb begin

/* State Machine
	States:
    	IDLE     
    	WB1    		
    	WB2     
    	FD1     
    	FD2     
    	WBD1    
    	WBD2     
    	DCHC     
    	INVAL    	
    	WRCNT   
    	FLUSH     	
*/
	
	//Next State Logic
	always_comb begin
		if (state == IDLE) begin
			if(dmemREN || dmemWEN) begin
				//if (!hit & )
			end
		end
	end

			

	//State Register
	always_ff @(posedge CLK,negedge nRST) begin
		if (nRST == 0) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule