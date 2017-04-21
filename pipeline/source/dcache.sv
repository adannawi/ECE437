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
    	INVAL    	= 4'b1001, 
    	//WRCNT     	= 4'b1010,
    	SNPD		= 4'b1010,
    	SNPWB1		= 4'b1011,
    	SNPWB2 		= 4'b1100,
    	FLUSHED    	= 4'b1101,
    	WRSNP		= 4'b1110, //Needed to invalidate other if memory is in shared.
    	WRINV		= 4'b1111  //Not a good design decision, but easier than changing how things get invalidtaed
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

	word_t block_data;

	// State Machine Output variables
	logic [15:0] clean; //Resets to dirty bits on read from mem
	logic word_sel;
	logic memtocache;


	//Memory Address to write cache data to when needed
	logic [31:0] mem_addr;

	//Indicates which index the write data is coming from for mem write
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

	//Coherence
	logic modified; //Indicates if whatever data currently being observed is modified
	logic invalid; //Indicates if whatever data currently being observed is invalid
	logic shared; //Inidicates if data is in shared

	logic snoop_respond; //Indicates if cache should be basing its ouput to memory controller based off of snooping
	logic [1:0] was_valid; //Indicates that the value being snooped was valid at the start of the snoop cycle
	logic way; //Indicates which way the dhit was on

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

/////////////////////////////////////////////////////////////
//					    was_valid
/////////////////////////////////////////////////////////////
//Set on SNOOP state to indicate if the data was valid then,

always_ff @(posedge CLK, negedge nRST) begin
	if (nRST == 0) begin
		was_valid <= 0;
	end else if (state == SNPD) begin
		//Use to indicate that there was a dhit but was invalidated by snooping
		was_valid <= 0; //Default to set which ever valid bit is not set to be 0
		if (way) begin
			was_valid[1] <= dhit;
		end else begin
			was_valid[0] <= dhit;
		end

	end else begin
		was_valid <= was_valid;
	end
end




/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////
//					Link Register
/////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//					Coherence Signals
/////////////////////////////////////////////////////////////
//Dat coherence tho

//assign ccif.write = 0;
//assign ccif.trans = 0;
/*
always_comb begin
	//Assert ccwait if its needed to indicate a wb, i.e. the cache has it in modified
	if (modified && cif.ccwait) begin
		cif.ccwrite = 1;

	//Else the other processor can get stuff from memory
	end else begin
		cif.ccwrite = 0;
	end
end*/

//Assign this comibinationally since it will get ignored UNLESS ccwait is asserted
//Asserted for when the data is in the cache, but not modified so the other must be invalidated
//Also asserted when writing and snooping other cache for data

always_comb begin
	//While snooping
	cif.ccwrite = 0;
	if (!snoop_respond) begin
		if (dcif.dmemWEN && ((dhit && !modified) || !dhit)) begin
			cif.ccwrite = 1;
		end else begin
			cif.ccwrite = 0;
		end

	//For being snooped
	end else if (snoop_respond) begin

		//For WB
		//I need to write back, will be asserted with CCtrans
		if (modified) begin
			cif.ccwrite = 1;

		//Set CCtrans when going to b

		//When asserted not with cctrans, means "go ahead and write, I don't have it"


		//When not in cache, tell it to go to mem 
		//end else if (invalid) begin
			//cif.ccwrite = 0;

		//Else hold at 0, coherence will dceide based on cctrans from this core (the one being snooped)
		end else begin
			cif.ccwrite = 0;
		end
	end
end

//Assert cctrans if the cache is changing state
//Possible transitions, causes
// I -> M   Writing to data not in cache, need to snoop to get from mem or WB
// I -> S   Reading data not in cache, need to snoop to get from mem or WB
// S -> M   This will happen when "I" write, will definitely need to invalidate other copies
// S -> I   Only will happen on flush or invalidate, do we need to assert?
// M -> I   When "I" have modified, other is invalidating, or flushing. Probably don't need a CCtrans for this
// M -> S   When "I" have modified, and other is reading. Need to WB so definitely assert FROM other


//FOR THIS TO WORK WE MUST HAVE THE DATA VALIDATED CORRECTLY AT THE RIGHT TIME
always_comb begin
	//Only assert when in states that maqe sense so that the coherence controller doesn't get out of sync

	//Set only on states
	if ((state == IDLE) || (state == FD1) || (state == WB1)) begin//|| (state == WBD1) || (state == WBD2) || (state == DCHK)) begin
		
		// I -> (M | S)
		// changed 'valid' to 'dsets[dcache.idx].way1.valid/2'
		if ((!dsets[dcache.idx].way1.valid || !dsets[dcache.idx].way2.valid) && (cif.dREN || cif.dWEN)) begin
			cif.cctrans = 1;

		// S -> M
		
		end else if ( (dsets[dcache.idx].way1.valid || dsets[dcache.idx].way2.valid) && cif.dWEN)begin
			cif.cctrans = 1;

		end else begin
			cif.cctrans = 0;
		end

	//Setting trans for snoop'd states
	//Could also try to set based off of 
	end else if ((state == SNPD) || (state == SNPWB1) || (state == SNPWB2) || (state == INVAL)) begin

		//Set cctrans to tell the coherence controller that the data is in the cache in case of hit
		//Handles WB and INVAL cases

		//When you need WB
		if (dhit && modified) begin
			cif.cctrans = 1;

		//Set cctrans to indicate that you need to invalidate (trust that ccwrite is set correctly)
		end else if (dhit && shared && cif.ccinv) begin
			cif.cctrans = 1; 

		//Else set to 0
		end else begin
			cif.cctrans = 0;
		end
	
	end else begin
		cif.cctrans = 0;
	end
end


/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/*	IMPORTANT COHERENCE NOTES
	It is VERY important that dhit is not asserted to the processor by the cache when coherence states are asserted

	What happens if we snoop an address EXACTLY as the processor goes into IDLE state? would that mean that the processor would take the new value as 
	it could be modified for snoop? Need to de-assert dhit in that case. Uses existing hardware to register a snoop hit
*/
always_comb begin
	if (snoop_respond) begin
		dcache = dcachef_t'(cif.ccsnoopaddr);
	end else begin
		dcache = dcachef_t'(dcif.dmemaddr);
	end
end


//Very close to the logic for dmemload setting
//assign dcif.dhit = (state == IDLE) && (next_state == IDLE) && (dcif.dmemWEN || dcif.dmemREN) && ((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1)) || ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1));
//assign dcif.dhit = (state == IDLE) && (next_state == IDLE) && (dcif.dmemWEN || dcif.dmemREN) && (((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1)) || ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1)));

//Assigning Processor's dhit for coherence
//Mainly should ALWAYS be 0 in case of 
always_comb begin
	//Prevent assertion of a dhit in case of a snoop. Prevents the processor from running with an address that is being snooped by the other core
	//This may be solved by LL/SC but this should eliminate some corner cases, if not optimize for it
	if (snoop_respond == 1) begin
		dcif.dhit = 0;
	end else begin 
		//Only really assign dhit for processor when there isn't a coherence operation
		dcif.dhit = dhit;
	end
end

always_comb begin
	dhit = 0;
	way = 0; //Set to 1 to indicate that the hit was in way 2, default of 0 indicates way 1
	if ((state == IDLE) && (dcif.dmemWEN || dcif.dmemREN)) begin
		//Match to way 1 at given IDX
		if ((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1)) begin
			dhit = 1;
			way = 0;

		//Match to way 2 at given IDX
		end else if ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1)) begin
			dhit = 1;
			way = 1;

		end
	//Snoop States hit matching
	end else if ((state == SNPD) || (state == SNPWB1) || (state == SNPWB1) || (state == INVAL)) begin
		if ((dsets[dcache.idx].way1.tag == dcache.tag) && ((dsets[dcache.idx].way1.valid == 1) || was_valid[0])) begin
			dhit = 1;
			way = 0; 

		//Match to way 2 at given IDX
		end else if ((dsets[dcache.idx].way2.tag == dcache.tag) && ((dsets[dcache.idx].way2.valid == 1) || was_valid[1])) begin
			dhit = 1;
			way = 1;

		end
	end
end

//Modified & valid logic
always_comb begin
	//There are 3 signals here, which despite being redundant should enhance clarity
	// modified | valid | invalid
	//These defaults are done to imply that there is no data match if the data is both modified and invalid
	modified = 0; 
	invalid = 0; //Should get set whenever something is actually found
	//Only care about tag matches
	if (dsets[dcache.idx].way1.tag == dcache.tag) begin
		if (dsets[dcache.idx].way1.valid) begin
			invalid = 0;
			modified = dsets[dcache.idx].way1.dirty;
		end
	end else if (dsets[dcache.idx].way2.tag == dcache.tag) begin
		if (dsets[dcache.idx].way2.valid) begin
			invalid = 0;
			modified = dsets[dcache.idx].way2.dirty;
		end
	end

	//Do we need to add signals here to indicate these correctly for when in snoop states? Might not be the safest
end

assign shared = !invalid && !modified;

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
		dcif.dmemload = dsets[0].way1.word1;
		if (dcache.blkoff == 0) begin
			dcif.dmemload = dsets[dcache.idx].way1.word1;
		end else begin
			dcif.dmemload = dsets[dcache.idx].way1.word2;
		end
	//Way 2
	end else if ((dcache.tag == dsets[dcache.idx].way2.tag) && dsets[dcache.idx].way2.valid) begin
		//If the tag matches and data is valid, must be one blocq or other
		dcif.dmemload = dsets[0].way2.word1;
		if (dcache.blkoff == 0) begin
			dcif.dmemload = dsets[dcache.idx].way2.word1;
		end else begin
			dcif.dmemload = dsets[dcache.idx].way2.word2;
		end
	end
end
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////
//					Memory address to write to
/////////////////////////////////////////////////////////////
//This never changes now that we're doing coherence, no need 
//to substitute to write counter

assign cif.daddr = mem_addr;


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
			if (cWEN[{dcache.idx,1'b0}]) begin

				//Write data, set dirty, MUST already be valid
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
			end else if (cWEN[{dcache.idx,1'b1}]) begin
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
			if (cWEN[{dcache.idx,1'b0}] == 1) begin
				//Write to first way
				dsets[dcache.idx].way1.word1 <= block_data;
				dsets[dcache.idx].way1.dirty <= 0;
				dsets[dcache.idx].way1.valid <= 0;

			end else if (cWEN[{dcache.idx,1'b1}] == 1) begin
				//If not first, Write to second way
				dsets[dcache.idx].way2.word1 <= block_data;
				dsets[dcache.idx].way2.dirty <= 0;
				dsets[dcache.idx].way2.valid <= 0;
			end
		end else if (state == FD2) begin

			if (cWEN[{dcache.idx,1'b0}] == 1) begin
				//Write to first way

				//Deal with special case where it will be written anyways
				if (dcif.dmemWEN && dcache.blkoff) begin
					//Write to word 2 if needed (woudl just overide anyways. if fetching data this means its just coming from mem so doesn't need snoop)
					dsets[dcache.idx].way1.word2 <= dcif.dmemstore;
					dsets[dcache.idx].way1.dirty <= 1;
					dsets[dcache.idx].way1.valid <= 1;
					dsets[dcache.idx].way1.tag <= dcache.tag;

				end else begin //Just these assignments was the original block
					//Default is storing data as normal
					dsets[dcache.idx].way1.word2 <= block_data;
					dsets[dcache.idx].way1.dirty <= 0;
					dsets[dcache.idx].way1.valid <= 1;
					dsets[dcache.idx].way1.tag <= dcache.tag;  //END of original
				end


				//Write to first word on getting second block if needed (will just override the other anyways on the next cycle)
				if (dcif.dmemWEN && !dcache.blkoff) begin
					dsets[dcache.idx].way1.word1 <= dcif.dmemstore;
					dsets[dcache.idx].way1.dirty <= 1;
					dsets[dcache.idx].way1.valid <= 1;
					dsets[dcache.idx].way1.tag <= dcache.tag;
				end

			end else if (cWEN[{dcache.idx,1'b1}] == 1) begin
				//If not first, Write to second way
							
				//If we want to write to this anyways, write off the bat
				if (dcif.dmemWEN && dcache.blkoff) begin
					//Write to word 2 if needed (woudl just overide anyways. if fetching data this means its just coming from mem so doesn't need snoop)
					dsets[dcache.idx].way2.word2 <= dcif.dmemstore;
					dsets[dcache.idx].way2.dirty <= 1;
					dsets[dcache.idx].way2.valid <= 1;
					dsets[dcache.idx].way2.tag <= dcache.tag;
				end else begin
					//Default is storing data as normal
					dsets[dcache.idx].way2.word2 <= block_data;
					dsets[dcache.idx].way2.dirty <= 0;
					dsets[dcache.idx].way2.valid <= 1;
					dsets[dcache.idx].way2.tag <= dcache.tag;
				end

				//Write to first word on getting second block if needed (will just override the other anyways on the next cycle)
				if (dcif.dmemWEN && !dcache.blkoff) begin
					dsets[dcache.idx].way2.word1 <= dcif.dmemstore;
					dsets[dcache.idx].way2.dirty <= 1;
					dsets[dcache.idx].way2.valid <= 1;
					dsets[dcache.idx].way2.tag <= dcache.tag;
				end
			end 	
		//end else if ((state == WRSNP) && (dhit)) begin	
		end else if ((state == WRINV) && (dhit)) begin	
			//Check for hit
			if (cWEN[{dcache.idx,1'b0}] == 1) begin
				//Write to first way
				dsets[dcache.idx].way1.word2 <= block_data;
				dsets[dcache.idx].way1.dirty <= 0;
				dsets[dcache.idx].way1.valid <= 1;
				dsets[dcache.idx].way1.tag <= dcache.tag;

			end else if (cWEN[{dcache.idx,1'b1}] == 1) begin
				//If not first, Write to second way
				dsets[dcache.idx].way2.word2 <= block_data;
				dsets[dcache.idx].way2.dirty <= 0;
				dsets[dcache.idx].way2.valid <= 1;
				dsets[dcache.idx].way2.tag <= dcache.tag;
			end 	
		end else if (state == INVAL) begin

			//On INVAL, invalidate way 1 if needed
			if (dsets[dcache.idx].way1.tag == dcache.tag) begin
				dsets[dcache.idx].way1.valid <= 0;

			//On INVAL, invalidate way 2 if needed
			end else if (dsets[dcache.idx].way2.tag == dcache.tag) begin
				dsets[dcache.idx].way2.valid <= 0;
			end
		end

		if ((state == SNPD) && (cif.ccinv) && dhit) begin
			//If in way 1, invalidate
			if (dsets[dcache.idx].way1.tag == dcache.tag) begin
				dsets[dcache.idx].way1.valid <=0;

			//Else invalidate way 2
			end else if (dsets[dcache.idx].way2.tag == dcache.tag) begin
				dsets[dcache.idx].way2.valid <=0;
			end
			
		end
		//Clean reset of dirty bits
		for (i = 0; i < 8; i++) begin
			if (dsets[i].way1.dirty == 1) begin
				if (clean[{i,1'b0}] == 1) begin
					dsets[i].way1.dirty <= 0;
				end
			end else if (dsets[i].way2.dirty == 1) begin
				if (clean[{i,1'b1}] == 1) begin
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
	if (state == WBD2 && !cif.dwait) begin
		clean[next_dirty] = 1;
	/*end else if (state == INVAL) begin
		//Setting correct clean on INVAL
		if ((dsets[dcache.idx].way1.tag == dcache.tag) && (dsets[dcache.idx].way1.valid == 1)) begin
			clean[{dcache.idx,1'b0}] = 1;

		//Match to way 2 at given IDX
		end else if ((dsets[dcache.idx].way2.tag == dcache.tag) && (dsets[dcache.idx].way2.valid == 1)) begin
			clean[{dcache.idx,1'b1}] = 1;

		end*/
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

//This selects JUST the WAY, not the WORD

always_comb begin
	//Default to no writes, safe practice, easier to catch
	cWEN = '0;

	//Never write on a snoop
	if (snoop_respond) begin
		cWEN = '0;

	//Write on hit, if not writing back from memory to cache block

	//REASONS WHY THIS DOESN'T WORK
	//	1. If both caches have data in shared, this just overwrote one without checking that it actually was written
	//	2. Maybe make another signal that indicates when a write was actually done which will prevent a dhit on a write until the write is actually done
	//		Cases when write is done
	//			S->M both in shared, one needs to snoop other to inval
	//          M->M already in modified, should just write
	//          I->M need to get from other cache
	//          I->M need to get from mem
	//	3. For a write when both are in shared, may need to go snoop the other cache and invalidate on WRSNP state to prevent other core from grabbing that value.
	//Should only do this write in modified
	end else if (dhit && dcif.dmemWEN && !memtocache && shared && (state == IDLE)) begin //Entering the danger zone here DANGER ZONE
		//Enable whichever index has the matching tag, & block
		//Indexes 000 to 111
		if (dsets[dcache.idx].way1.tag == dcache.tag) begin
			cWEN[{dcache.idx,1'b0}] = 1;
		end else  begin
			//Will not have a hit if this second one mdoesn't match, so can use an else instead of if else
			cWEN[{dcache.idx,1'b1}] = 1;
		end

	end else if (dhit && dcif.dmemWEN && !memtocache && shared && (state == WRSNP)) begin
		//Enable whichever index has the matching tag, & block
		//Indexes 000 to 111
		if (dsets[dcache.idx].way1.tag == dcache.tag) begin
			cWEN[{dcache.idx,1'b0}] = 1;
		end else  begin
			//Will not have a hit if this second one mdoesn't match, so can use an else instead of if else
			cWEN[{dcache.idx,1'b1}] = 1;
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

			cWEN[{dcache.idx,1'b0} + lru[dcache.idx]] = 1;

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
	lru <= lru;
	if (!nRST) begin 
		lru <= '0;

	//LRU set on a write, only do on a hit because 
	//  Values for LRU:
	//  way1 -> 0, way2 -> 1
	//  e.g. if LRU[i] = 1, way 2 is LRU and should be replaced

	//Set LRU on hit for write
	end else if (dcif.dmemWEN && (state == IDLE) && dhit) begin
		//Iterate through to find whatever is being written

		//Check current index, way 1
		if (cWEN[{dcache.idx,1'b0}]) begin
				//This should work in any case for a write, because
				//if a block is fetched from memory then it will be 
				//written to or read at the end in idle state
				//Also when it is fetched and written into memory,
				//the write will be enabled, meaning that it LRU will
				//be set then. 
				// Can be set to whichever way is not set 
			lru[dcache.idx] <= 1;

		//Check current index, way 2
		end else if  (cWEN[{dcache.idx,1'b1}]) begin
			lru[dcache.idx] <= 0;

		//Else maintain
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
//			  Mem. Write/Read Destination Logic
/////////////////////////////////////////////////////////////

//Selects the location that memory will be written to
always_comb begin
	//Defaults
	mem_addr = 32'hECE43700; //Error value, this should never be hit
	data_way = 0;
	data_idx = 0;

	//For WRITING back DIRTY bits
	if ((state == WBD1) || (state == WBD2)) begin
		//Select based off of next_dirty
		data_way = next_dirty[0];
		data_idx = next_dirty[3:1];

		if (next_dirty[0] == 0) begin
			//Select Way 1
			mem_addr = {dsets[next_dirty[3:1]].way1.tag, next_dirty[3:1], word_sel, 2'b00};
		end else if (next_dirty[0] == 1) begin
			//Select Way 2
			mem_addr = {dsets[next_dirty[3:1]].way2.tag, next_dirty[3:1], word_sel, 2'b00};
		end

		//Address to write data ALREADY IN CACHE back to
	end else if ((state == WB1) || (state == WB2) || (state == SNPWB1) || (state == SNPWB2)) begin
		//Select based off of current data trying to be READ or WRITTEN and LRU
		data_way = lru[dcache.idx];
		data_idx = dcache.idx;

		//This needs to pay attention to LRU to verify writeback to correct address
		if (lru[dcache.idx] == 0) begin
			//Select Way 1
			mem_addr = {dsets[dcache.idx].way1.tag, dcache.idx, word_sel, 2'b00};

		end else if (lru[dcache.idx] == 1) begin
			//Select Way 2
			mem_addr = {dsets[dcache.idx].way2.tag, dcache.idx, word_sel, 2'b00};
		end

		//Address to read from for FRESH DATA -> where to put it selected elsewhere
	//end else if ((state == FD1) || (state == FD2)) begin

	end else begin 
		//Default to read
		mem_addr = {dcache.tag, dcache.idx, word_sel, 2'b00};
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

	//Write data from cache
	if (data_way) begin
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
	assign miss = !dhit;
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
				if (dcif.halt) begin
					//On halt when not already getting data, go to write back dirty sta
					next_state = DCHK;

				end else if (cif.ccwait) begin
					next_state = SNPD;

				end else if (miss && (dcif.dmemREN | dcif.dmemWEN)) begin
					//WB states based on LRU if data remaining is valid
					if ((lru[dcache.idx] && dsets[dcache.idx].way2.dirty) && dsets[dcache.idx].way2.valid) begin
						next_state = WB1;
					end else if ((!lru[dcache.idx] && dsets[dcache.idx].way1.dirty) && dsets[dcache.idx].way1.valid) begin
						next_state = WB1;
					end else begin
						next_state = FD1;
					end

				//On a hit just stay IDLE
				end else if (dhit && !shared) begin
					next_state = IDLE;

				end else if (dhit && shared) begin 
					next_state = WRSNP;

				end else begin
					next_state = IDLE;
				end
			end

			WB1: begin
				//Move on if not waiting on memory
				if (cif.ccwait) begin
					next_state = SNPD;

				end else if (!cif.dwait) begin
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
				if (cif.ccwait) begin
					next_state = SNPD;

				end else if (!cif.dwait) begin
					next_state = FD2;

				//Else keep waiting
				end else begin
					next_state = state;
				end 
			end

			FD2: begin
				//Go to inval if writing
				if (!cif.dwait && dcif.dmemWEN && cif.ccinv) begin
					next_state = WRINV;

				//Go back to idle if not writing
				end else if (!cif.dwait) begin
					next_state = IDLE;
				
				//Else keep waiting
				end else begin
					next_state = state;
				end
			end

			DCHK: begin 
				// Need way to check if dirty or not -> use dirty bits, will be cleaned in DWB2
				//Assume clean until dirty is found
				next_state = FLUSHED; // WRCNT doesn't exist anymore

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

			INVAL: begin
				next_state = IDLE;
			end

			SNPD: begin
				//Hit determines if its in the cache, if not must be invalid
				//modified signal will determine whether or not the selected data is dirty

				//WB if dirty
				if (dhit && modified) begin
					next_state = SNPWB1;

				//Move this cache to INVAL if needed
				end else if (dhit && cif.ccinv) begin
					next_state = INVAL;

				//Keep this cache in SNPD if waiting for other core to finish (for Shared in both, waiting for mem OP)
				//end else if (cif.ccwait) begin
				//	next_state = SNPD;
				// ^^^^^ I think this is excessive, could run into issues when this should be serviced next, but won't assert that it needs to be serviced until cycle
				//		  after the other core finishes, may be ready to be serviced again. As long as coherence holds the cif.ccwait this will just keep checking
				//		  to see if coherence is done.
				//		
				//			MAY NEED TO READD ARBITRATE STATE FOR THE CASE WHERE THIS KEEPS GOING BACK TO CHECK IF SNOOP IS DONE, BUT OTHER IS JUST COMPLETED
				//			AND THIS CORE WILL NOT PROPERLY ASSERT THAT IT WANTS TO PERFORM AN OPERATION UNTIL IT IS A CYCLE LATE. ASSERTING THIS IN SNOOP MAY
				//			BE SUFFICIENT SINCE THE OTHER CORE WILL BE IN WB1/FD1 AND CAN GO TO SNOOPED FORM THERE
				end else if (cif.ccwait == 0) begin
					next_state = IDLE;

				end else begin
					next_state = SNPD;
				//Default for when 
				/*end else begin
					//Else in shared and other core needs to just go Read from Mem
					next_state = IDLE;*/
				end
			end

			SNPWB1: begin
				
				if (cif.dwait == 0) begin
					next_state = SNPWB2;

				end else begin
					//Default
					next_state = SNPWB1;
				end
			end

			SNPWB2: begin

				if ((cif.dwait == 0) && (cif.ccinv == 1)) begin
					next_state = INVAL;

				end else if (cif.dwait == 0) begin
					next_state = IDLE;

					
				end else begin
					//Default
					next_state = SNPWB2;
				end
			end

			WRSNP: begin
				//if (cif.ccinv) begin
				//	next_state = IDLE;
				//end else begin
					next_state = WRINV;
				//end
			end

			WRINV: begin
				next_state = IDLE;
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
		snoop_respond = 0;

		casez(state)
		
			IDLE: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
			end

			WB1: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
			end

			WB2: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 1;
			end

			FD1: begin
				dcif.flushed = 0;
				cif.dREN = 1;
				cif.dWEN = 0;
				word_sel = 0;
				memtocache = 1;
			end

			FD2: begin
				dcif.flushed = 0;
				cif.dREN = 1;
				cif.dWEN = 0;
				word_sel = 1;
				memtocache = 1;
			end

			DCHK: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
			end

			WBD1: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
			end

			WBD2: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 1;
			end

			//I think this is a state I put in originally that is unneeded
			INVAL: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
				snoop_respond = 1;
			end

			/*WRCNT: begin
			dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
			end
			*/

			SNPD: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
				snoop_respond = 1;
			end

			FLUSHED: begin
				dcif.flushed = 1;
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;;
			end // FLUSHED:

			SNPWB1: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 0;
				snoop_respond = 1;
			end

			SNPWB2: begin
				dcif.flushed = 0;
				cif.dREN = 0;
				cif.dWEN = 1;
				word_sel = 1;
				snoop_respond = 1;
			end

			WRSNP: begin
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
				dcif.flushed = 0;
				memtocache = 0;
			end

			WRINV: begin
				cif.dREN = 0;
				cif.dWEN = 0;
				word_sel = 0;
				dcif.flushed = 0;
				memtocache = 0;
			end

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