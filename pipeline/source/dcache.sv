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
		logic [DTAG_W-1:0] tag;
		word_t word1;
		word_t word2;
	 } dway;

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
    	DCHK     	= 4'b1000,
    	INVAL    	= 4'b1001,
    	WRCNT     	= 4'b1010,
    	FLUSHED    	= 4'b1011
	} Statetype;

	//Local Variables

	//	States for cache function
	Statetype state;
	Statetype next_state;

	//	Data for 
	dset [7:0] dsets;
	dcachef_t dcache; //Breacc down of address into smaller values
	integer i;
	logic miss;

	//Counts
	word_t count;
	word_t miss_count;
	word_t hit_count;
	word_t block_data;

	// State Machine Output variables
	logic [15:0] clean; //Resets to dirty bits on read from mem


	//Write Enables
	//Accounts for every way but not the block within the way
	logic [15:0] cWEN;

	logic [7:0] lru;dhit
	logic dhit;

    //   26 bits tag | 3 bits idx | 1 bit block offset | 2 bits of byte offset (4 bytes/32 bits)
	assign dcache = dcachef_t'(dcif.imemaddr);

  //	DATAPATH_CACHE_IF
  //	This is where inputs from datapath come from
  // datapath cache if dcache ports
  //modport dcache (
  //  input   halt, dmemREN, dmemWEN,
  //          datomic, dmemstore, dmemaddr,
  //  output  dhit, dmemload, flushed
  //);

  //  CACHES_IF -> cif
  // dcache ports to controller
  //modport dcache (
  //input   dwait, dload,
  //        ccwait, ccinv, ccsnoopaddr,
  //output  dREN, dWEN, daddr, dstore,
  //        ccwrite, cctrans
  //);


//Very close to the logic for dmemload setting
assign dcif.dhit = (dcif.dmemWEN || dcif.dmemREN) && ((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1)) || ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1));
assign dhit = dcif.dhit; //Purely to make it easier to reference

  //typedef struct packed {
  //  logic [DTAG_W-1:0]  tag;
  //  logic [DIDX_W-1:0]  idx;
  //  logic [DBLK_W-1:0]  blkoff;
  //  logic [DBYT_W-1:0]  bytoff;
  //} dcachef_t;

 //typedef struct packed {
//		logic valid;
//		logic dirty;
//		logic [ITAG_W-1:0] tag;
//		word_t word1;
//		word_t word2;
//	 } dway;


/////////////////////////////////////////////////////////////
//Logic for reading out of cache
/////////////////////////////////////////////////////////////
//Data to read (does not mean it is valid - via dhit)
always_comb begin
	//Default is to match to first set's first way's first block -> does not mean valid
	//Should write a notable value here to verify for testing
	dcif.dmemload = dsets[0].way1.word1;

	//Checq the index matching the dcache
	//Way 1
	if ((dcache.tag == dsets[dcache.idx].way1.tag) && dsets[dcache.idx].way1.valid) begin
		//If the tag matches and data is valid, must be one blocq or other
		if (dcache.blkoff == 0) begin
			dcif.dmemload = dsets[dcache.idx].way1.word1;
		end else begin
			dcif.dmemload = dsets[dcache.idx].way1.word2;
		end
	//Way 2
	end else if ((dcache.tag == dsets[dcache.idx].way2.tag) && dsets[dcache.idx].way2.valid) begin
		//If the tag matches and data is valid, must be one blocq or other
		if (dcif.dmemload.blkoff == 0) begin
			block_read = dsets[i].way2.word1;
		end else begin
			dcif.dmemload = dsets[i].way2.word2;
		end
	end
end
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//Counters for count of original dhits
/////////////////////////////////////////////////////////////

//Hit Counter
always_ff @(posedge CLK, negedge nRST) begin
	if (nRST == 0) begin
		hit_count <= 0;
	end else if (dhit) begin
		hit_count <= hit_count + 1;
	end else begin
		hit_count <= hit_count;
	end
end

//Miss Counter
always_ff @(posedge CLK, negedge nRST) begin
	if (nRST == 0) begin
		hit_count <= 0;
	end else if (miss_count) begin
		hit_count <= hit_count + 1;
	end else begin
		hit_count <= hit_count;
	end
end

//Overall count
assign count = hit_count - miss_count;

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

//Store value
assign cif.dstore = (dcif.dmemload && !write_counter) || (count && write_counter);



/////////////////////////////////////////////////////////////
//Sets Registers
/////////////////////////////////////////////////////////////
			//WHERE to write (factors)?
			//	idx
			//	LRU
			//	ALWAYS to word 1 for FD1, 2 for FD2 -> will be in register

			//WHEN to write is handled by state machine and factors in
			//	LRU data should already be written back
			//	Data must be valid (state machine/registers?)

			//WHAT to write (done with registers)
			//	Tag of whatever is requested (this can be done for both writes no trouble)
			//	Data supplied by memory
			//	Set valid when writing to (True for all writes until multicore)
			//	Set clean when written from memory

//	Register Sets -> updates for writes, read is set elsewhere


//NEED TO ADD CLEANING FOR WHEN DATA IS BEING FLUSHED

always_ff @ (posedge CLK, negedge nRST)
begin
	if (!nRST) begin
		for (i = 0; i < 8; i++) begin // Reset all 16 sets
			dsets[i].way1.valid <= 0;
			dsets[i].way1.dirty <= 0;
			dsets[i].way1.tag <= 0;
			dsets[i].way1.word1 <= 0;
			dsets[i].way1.word2 <= 0;
			dsets[i].way2.valid <= 0;
			dsets[i].way2.dirty <= 0;
			dsets[i].way2.tag <= 0;
			dsets[i].way2.word1 <= 0;
			dsets[i].way2.word2 <= 0;
		end
	end else begin
		//Defaults to avoid latches
		dsets <= dsets;

		//Write on Hit, state idle
		if (dhit && (state == IDLE)) begin

			//Check first way in set
			if (cWEN[dcache.idx*2]) begin

				//Write data, set dirty, should already be valid
				if (dcache.blkoff == 0) begin
					//Write to first block if offset == 0
					dsets[dcache.idx].way1.word1 <= block_data;
					dsets[dcache.idx].way1.dirty <= 1;
				end else begin
					//Else since there was a cWEN, must match block 2
					dsets[dcache.idx].way1.word2 <= block_data;
					dsets[dcache.idx].way1.dirty <= 1;
				end

			//Check Second way
			end else if (cWEN[(dcache.idx*2)+1]) begin
				if (dcache.blkoff == 0) begin
					//Write to first block if offset == 0
					dsets[dcache.idx].way2.word1 <= block_data;
					dsets[dcache.idx].way2.dirty <= 1;
				end else begin
					//Else since there was a cWEN, must match block 2
					dsets[dcache.idx].way2.word2 <= block_data;
					dsets[dcache.idx].way2.dirty <= 1;
				end
			end
		end

		//Write based on states when replacing data (assume written back)
		end else if (state == FD1) begin
			//Write to block 1 of whatever index is indicated -> where set by cWEN
			if (cWEN[dcache.idx*2] == 1) begin
				//Write to first way
				dsets[dcache.idx].way1.word1 <= block_data;
				dsets[dcache.idx].way1.dirty <= 0;
				dsets[dcache.idx].way1.valid <= 1;

			end else if (cWEN[dcache.idx*2 + 1] == 1) begin
				//If not first, Write to second way
				dsets[dcache.idx].way2.word1 <= block_data;
				dsets[dcache.idx].way2.dirty <= 0;
				dsets[dcache.idx].way2.valid <= 1;
			end
		end else if (state == FD2) begin

			if (cWEN[dcache.idx*2] == 1) begin
				//Write to first way
				dsets[dcache.idx].way1.word2 <= block_data;
				dsets[dcache.idx].way1.dirty <= 0;
				dsets[dcache.idx].way1.valid <= 1;

			end else if (cWEN[dcache.idx*2 + 1] == 1) begin
				//If not first, Write to second way
				dsets[dcache.idx].way2.word2 <= block_data;
				dsets[dcache.idx].way2.dirty <= 0;
				dsets[dcache.idx].way2.valid <= 1;
			end 			
		end
	end
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//Cache Write Enable logic (cWEN)
/////////////////////////////////////////////////////////////

//This takes into account validity of bits
//Will tell registers if they need to actually store the informatin
//CHecks each of the 16 tags, but does not deal with blkoffset
//Does tag comparision to find the match
//Similar to the hit logic, but separate for clarity's sake

always_comb begin
	//Default to no writes, safe practice, easier to catch
	cWEN = '0;

	//Write on hit, if not writing back from memory to cache block
	if (dhit && dcif.dmemWEN && !memtocache) begin
		//Enable whichever index has the matching tag, & block
		//Indexes 000 to 111
		if (dsets[dcache.idx].way1.tag == dcache.tag) begin
			cWEN[dcache.idx * 2] = 1;
		end else  begin
			//Will not have a hit if this second one mdoesn't match, so can use an else instead of if else
			cWEN[dcache.idx * 2 + 1] = 1;
		end
	//end else if ((state == FD1) && !cif.dwait) begin
	end else if (((state == FD1) || (state == FD2)) && !cif.dwait)begin
			//Enable write to whatever matches desired index, and is LRU. 
			//LRU will not be updated here so there's no write where the
			//first half is correctly written to the LRU, and the other
			//half is written to the !LRU

			//WHERE to write (factors)?
			//	idx
			//	LRU
			//	ALWAYS to word 1 for FD1, 2 for FD2 -> will be in register

			cWEN[dcache.idx*2 + lru[dcache.idx]] = 1;

			//WHEN to write is handled by state machine and factors in
			//	LRU data should already be written back
			//	Data must be valid (state machine/registers?)

			//WHAT to write (done with registers)
			//	Tag of whatever is requested (this can be done for both writes no trouble)
			//	Data supplied by memory 

	end
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////
//Block write data selection logic
/////////////////////////////////////////////////////////////
always_comb begin
	if (memtocache) begin
		//Write to block indicated by state machine, enable only 
		block_data = cif.dload;
	end else begin
		//Else write just to what's indicated by block offset
		block_data = dcif.dmemstore;
	end
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//LRU      
/////////////////////////////////////////////////////////////

//LRU is set to indicate which way was LRU, i.e. if 
//Way 1 was last used, then LRU = 1 to indicate Way 2 is LRU
//Notably this can be used to index the WEN desired to be set
//by adding LRU to i*2 which will be useful for block replacement
always_ff @(posedge CLK, negedge nRST) begin

	lru <= lru;

	if (!nRST) begin 
		lru <= '0;

	//LRU set on a write, only do on a hit because 
	//  Values for LRU:
	//  way1 -> 0, way2 -> 1
	//  e.g. if LRU[i] = 1, way 2 is LRU and should be replaced
	end else if (dcif.dmemWEN && (state == IDLE) && dhit) begin
		//Iterate through to find whatever is being written

		if (cWEN[dcache.idx*2]) begin
				//This should work in any case for a write, because
				//if a block is fetched from memory then it will be 
				//written to or read at the end in idle state
				//Also when it is fetched and written into memory,
				//the write will be enabled, meaning that it LRU will
				//be set then. 
				// Can be set to whichever way is not set 
			lru[dcache.idx] <= 1;

		end else if  (cWEN[dcache.idx*2 + 1]) begin
			lru[dcache.idx] <= 0;

		end else begin
			lru[dcache.idx] <= lru[dcache.idx];

		end

	//LRU set on a read
	end else if (dcif.dmemREN && (state == IDLE) && dhit) begin
		//Check only given idx, match 
		if (dsets[dcache.idx].way1.tag == dcache.tag) begin
			lru[dcache.idx] = 1;

		end else if( dsets[j].way2.tag == dcache.tag) begin
			lru[dcache.idx] = 0;
		end

	end else begin
		lru <= lru;
	end
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////
//					  State Machine
/////////////////////////////////////////////////////////////

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