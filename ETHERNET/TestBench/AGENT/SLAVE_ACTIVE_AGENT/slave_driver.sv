
	///////////////////////////////////////////////////////
	//     IN THIS APB SLAVE DRIVER CLASS WE HAVE TO     //
	//      WRITE LOGIC FOR  DRIVING M_PREADY SIGNAL     //
	///////////////////////////////////////////////////////



class apb_slave_driver extends uvm_driver#(sequence_item);

	`uvm_component_utils(apb_slave_driver)     	     				//------ FACTORY REGISTRATION

	virtual intf h_intf;											//------ INSTANCE FOR INTERFACE
		
	
	function new(string name = "apb_slave_driver",uvm_component parent);
		super.new(name,parent);
	endfunction
  
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		req = sequence_item::type_id::create("req");				//------ OBJECT CREATION FOR SEQUENCE ITEM
      	forever 
			begin 
				@(h_intf.cb_slave_driver)
		
				wait(h_intf.cb_slave_driver.m_psel_o && h_intf.cb_slave_driver.m_penable_o)  //--- CONDITION CHECKING FOR SELECTION  ENABLE 
					begin		
					h_intf.cb_slave_driver.m_pready_i <= 1;
					end
	
                   
      		end
	endtask
	
	/////////////////////////////////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS AND GETTING THE INTERFACE   //
	/////////////////////////////////////////////////////////////////////////////

  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));		//--- getting interface from top....
  endfunction
endclass
