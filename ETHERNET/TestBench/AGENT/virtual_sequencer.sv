
	/////////////////////////////////////////////////////////////////////////////////
	//     IN THIS virtual SEQUNCER CLASS WE HAVE TO CREATE A CONSTRUCTOR FOR IT   //
	/////////////////////////////////////////////////////////////////////////////////

class virtual_sequencer extends uvm_sequencer#(sequence_item);

	`uvm_component_utils(virtual_sequencer)     				//------ FACTORY REGISTRATION

	master_sequencer h_m_seqr;

	rx_mac_sequencer h_rx_mac_seqr;

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////

	function new(string name = "virtual_sequencer",uvm_component parent);
		super.new(name,parent);
	endfunction

endclass
