`include "caches_if.vh"
`include "cpu_types_pkg.vh"
`include "datapath_cache_if.vh"

module dcache (
	input logic CLK, nRST,
	datapath_cache_if.dcache dcif,
	caches_if.dcache cif
	);
	
	import cpu_types_pkg::*;

	typedef struct packed {
		logic valid;
		logic dirty;
		logic [DTAG_W-1:0] tag;
		word_t word1;
		word_t word2;
	 } dway;

	typedef struct packed {
		dway way1;
		dway way2;
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
    	INVAL    	= 4'b1001, //Extra, not needed anymore
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
	logic writecounter;

	// State Machine Output variables
	logic [15:0] clean; //Resets to dirty bits on read from mem
	logic word_sel;
	logic memtocache;


	//Memory Address to write cache data to when needed
	logic [31:0 ]mem_addr;

	//Indicates which index the write data is coming form for mem write
	logic [2:0] data_idx;

	//Indicates which way for the index the data is selected
	logic data_way;

	//Write Enables
	//Accounts for every way but not the block within the way
	logic [15:0] cWEN;

	logic [7:0] lru;
	logic dhit;

	//Indicates next dirty data to write back
	logic [3:0] next_dirty;
	logic some_dirty;


    //   26 bits tag | 3 bits idx | 1 bit block offset | 2 bits of byte offset (4 bytes/32 bits)
	

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

assign dcache = dcachef_t'(dcif.dmemaddr);
//Very close to the logic for dmemload setting
assign dcif.dhit = (dcif.dmemWEN || dcif.dmemREN) && ((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1)) || ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1));
assign dhit = dcif.dhit; //Purely to make it easier to reference



/////////////////////////////////////////////////////////////
//			Logic for reading out of cache
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
		if (dcache.blkoff == 0) begin
			dcif.dmemload = dsets[i].way2.word1;
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
		miss_count <= 0;
	end else if (miss && state == FD1) begin
		miss_count <= miss_count + 1;
	end else begin
		miss_count <= miss_count;
	end
end

//Overall count
assign count = hit_count - miss_count;
assign miss = !dhit;

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////
//					Memory address to write to
/////////////////////////////////////////////////////////////
//Store value

always_comb begin
	if (writecounter) begin
		cif.daddr = 32'h00003100;
	end else begin
		//Change to select from cache based on data idx/data way values
		cif.daddr = mem_addr;
	end // end else
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
	

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

		//Clean reset of dirty bits
		for (i = 0; i < 8; i++) begin
			if (dsets[i].way1.dirty == 1) begin
				if (clean[i*2] == 1) begin
					dsets[i].way1.dirty <= 0;
				end
			end else if (dsets[i].way2.dirty == 1) begin
				if (clean[i*2 + 1] == 1) begin
					dsets[i].way2.dirty <= 0;
				end
			end
		end
	end
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////
//					Clean setting for WB
/////////////////////////////////////////////////////////////
//Store value

always_comb begin
	clean = '0;
	if (state == WBD2) begin
		clean[next_dirty] = 1;
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
//Selects what data will be selected for writing into the cache
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
			lru[dcache.idx] <= 1;

		end else if (dsets[dcache.idx].way2.tag == dcache.tag) begin
			lru[dcache.idx] <= 0;
		end

	end else begin
		lru <= lru;
	end 
end

/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////
//					  Next Dirty to WB
/////////////////////////////////////////////////////////////
logic [3:0] k;
//For selecting next dirty value to write back
always_comb begin
	//Defaults
	next_dirty = 0;
	some_dirty = 0;
	for (k = 0; k < 8; k++) begin
		if (dsets[k].way1.dirty) begin
			next_dirty = {k[2:0],1'b0};
			some_dirty = 1;
		end else if (dsets[k].way2.dirty) begin
			next_dirty = {k[2:0],1'b1};
			some_dirty = 1;			
		end
	end // for (i = 0; i < 8; i++)
end
 
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//				 Mem. Write Destination Logic
/////////////////////////////////////////////////////////////

//Selects the location that memory will be written to
always_comb begin
	mem_addr = 32'hECE43700; //Error value, this should never be hit
	data_way = 0;
	if ((state == WBD1) || (state == WBD2)) begin
		//Select based off of next_dirty
		data_way = next_dirty[0];
		data_idx = next_dirty[3:1];
		if (next_dirty[0] == 0) begin
			//Select Way 1
			mem_addr = {dsets[next_dirty[3:1]].way1.tag, next_dirty[3:1], word_sel, 2'b00};
		end else if (next_dirty[1] == 1) begin
			//Select Way 2
			mem_addr = {dsets[next_dirty[3:1]].way2.tag, next_dirty[3:1], word_sel, 2'b00};
		end

	end else begin
		//Select based off of current data trying to be written and LRU
		data_way = lru[dcache.idx];
		data_idx = dcache.idx;
		if (lru[dcache.idx] == 0) begin
			//Select Way 1
			mem_addr = {dsets[dcache.idx].way1.tag, dcache.idx, word_sel, 2'b00};

		end else if (lru[dcache.idx] == 1) begin
			//Select Way 2
			mem_addr = {dsets[dcache.idx].way2.tag, dcache.idx, word_sel, 2'b00};
		end

	end

end
		//Write 
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//				 Memory Write data Selection
/////////////////////////////////////////////////////////////

//Selects the value that memory will be written
always_comb begin
	cif.dstore = 32'hECE43700;

	//Write counter
	if (writecounter) begin
		cif.dstore = count;

	//Write data from cache
	end else if (data_way) begin
		if (word_sel) begin
			cif.dstore = dsets[data_idx].way2.word2;
		end else begin
			cif.dstore = dsets[data_idx].way2.word1;
		end
	end else begin
		if (word_sel) begin
			cif.dstore = dsets[data_idx].way1.word2;
		end else begin
			cif.dstore = dsets[data_idx].way1.word1;
		end
	end
end
		//Write 
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//					  State Machine
/////////////////////////////////////////////////////////////

//Block selection data logic

/* State Machine
	States:
    	IDLE     
    	WB1    		
    	WB2     
    	FD1     
    	FD2     
    	WBD1    
    	WBD2     
    	DCHK     
    	INVAL    	
    	WRCNT   
    	FLUSHED     	
*/
	
	//Next State Logic
	always_comb begin	
		//if (state == IDLE) begin
		//	if(dmemREN || dmemWEN) begin
		//		//if (!hit & )
		//	end
		//end
		next_state = state;
		
		casez(state)
			//Default for all states: wait
			
			IDLE: begin
				//Cache memory dirty on miss
				//Only matters if both ways are dirty, or the empty slot will be LRU
				if (miss) begin
					if (lru[dcache.idx] && dsets[dcache.idx].way2.dirty) begin
						next_state = WB1;
					end else if (!lru[dcache.idx] && dsets[dcache.idx].way1.dirty) begin
						next_state = WB1;
					end else begin
						next_state = FD1;
					end

				//On a hit just stay IDLE
				end else if (dhit) begin
					next_state = IDLE;

				//On halt when not already getting data, go to write back dirty stages
				end else if (dcif.halt) begin
					next_state = DCHK;
				end
			end

			WB1: begin
				//Move on if not waiting on memory
				if (!cif.dwait) begin
					next_state = WB2;

				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			WB2: begin
				//Move on to fetch data once memory is done
				if (!cif.dwait) begin
					next_state = FD1;

				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			FD1: begin
				//Move to get second word if memory done
				if (!cif.dwait) begin
					next_state = FD2;

				//Else keep waiting
				end else begin
					next_state = state;
				end 
			end

			FD2: begin
				//Go back to idle once done getting data
				if (!cif.dwait) begin
					next_state = IDLE;
				
				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			DCHK: begin 
				// Need way to check if dirty or not -> use dirty bits, will be cleaned in DWB2
				//Assume clean until dirty is found
				next_state = WRCNT;

				//If any are dirty go to write back. Other logic will select the index to write
				if (some_dirty) begin
					next_state = WBD1;
				end
			end

			WBD1: begin
				//Move on if memory is done
				if (!cif.dwait) begin
					next_state = WBD2;
				
				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			WBD2: begin
				//Move on if memory is good
				if (!cif.dwait) begin
					next_state = DCHK;
				
				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			//I think this is a state I put in originally that is unneeded
			INVAL: begin
				next_state = IDLE;
			end

			WRCNT: begin
				if (!cif.dwait) begin
					next_state = FLUSHED;
				
				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			default: begin
				next_state = state;
			end // default:
		endcase
	end // always_comb

	
	//use dcif.flushed
	//use cif.dREN
	//use cif.dWEN
	//use clean[15:0]
	//use word_sel

	// Output Logic
	always_comb begin
		// Defaults 
		memtocache = 0;
		dcif.flushed = 0;
		cif.dREN = 0;
		cif.dWEN = 0;
		word_sel = 0;
		//	clean = 0;
		writecounter = 0;

		casez(state)
		
			IDLE: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
			//	clean = 0;
				writecounter = 0;
			end

			WB1: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
			//	clean = 0;
				writecounter = 0;
			end

			WB2: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 1;
			//	clean = 1;
				writecounter = 0;
			end

			FD1: begin
				dcif.flushed = 0;
				cif.dREN = 1;
				cif.dWEN = 0;
				word_sel = 0;
			//	clean = 0;
				writecounter = 0;
				memtocache = 1;
			end

			FD2: begin
				dcif.flushed = 0;
				cif.dREN = 1;
				cif.dWEN = 0;
				word_sel = 1;
			//	clean = 0;
				writecounter = 0;
				memtocache = 1;
			end

			DCHK: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
			//	clean = 0;
				writecounter = 0;
			end

			WBD1: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
			//	clean = 0;
				writecounter = 0;
			end

			WBD2: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 1;
			//	clean = 1;
				writecounter = 0;
			end

			//I think this is a state I put in originally that is unneeded
			INVAL: begin
				// ?
			end

			WRCNT: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
			//	clean = 0;
				writecounter = 1;
			end

			FLUSHED: begin
				dcif.flushed = 1;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
			//	clean = 0;
				writecounter = 0;
			end // FLUSHED:
		endcase
	end // always_comb

			

	//State Register
	always_ff @(posedge CLK,negedge nRST) begin
		if (nRST == 0) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end // always_ff @(posedge CLK,negedge nRST)

endmodule