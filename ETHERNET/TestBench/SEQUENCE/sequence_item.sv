
//////////////////////////////////////////////////////////////////////////
//     IN THIS SQUENCE ITEM CLASS WE HAVE TO DECLARE ALL THE SIGNAL     //
//////////////////////////////////////////////////////////////////////////

class sequence_item extends uvm_sequence_item;

	`uvm_object_utils(sequence_item)   						//------ FACTORY REGISTRATION

	/////////////////////////////
	//     SIGANLS OF HOST     //
	/////////////////////////////

	randc bit prstn_i;
	randc bit [31:0] paddr_i;
	randc bit [31:0] pwdata_i;
		  bit [31:0] prdata_o;
	randc bit psel_i;
	randc bit pwrite_i;
	randc bit penable_i;
		  bit pready_o;
		  bit int_o;

	////////////////////////////
	//     MEMORY SIGNALS     //
	////////////////////////////

	randc bit [31:0] m_prdata_i;
	randc bit m_pready_i;
		  bit [31:0] m_paddr_o;
		  bit [31:0] m_pwdata_o;
		  bit m_psel_o;
		  bit m_penable_o;
		  bit m_pwrite_o;

	/////////////////////////
	//     MAC SIGNALS     //
	/////////////////////////

	randc bit MRxDV=0;
	randc bit [3:0] MRxD;
	randc bit MRxErr;
	randc bit MCrS=0;	

	/////////////////////////////////////////////////////
	//     NEW CONSTRUCTOR FOR FOR CREATING MEMORY     //
	/////////////////////////////////////////////////////
	
	function new(string name = "sequence_item");
		super.new(name);
	endfunction
endclass
