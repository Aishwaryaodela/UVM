
	////////////////////////////////////////////////////////
	//     IN THIS APB MASTER DRIVER CLASS WE HAVE TO     //
	//     WRITE LOGIC FOR APB PROTOCOL BASED DRIVING     //
	////////////////////////////////////////////////////////

class master_driver extends uvm_driver#(sequence_item);

	`uvm_component_utils(master_driver)     					//------ FACTORY REGISTRATION

	virtual intf h_intf;										//------ INSTANCE FOR INTERFACE

	config_class h_config;  									//------ CONFIG CLASS HANDLE DECLARATION

  	uvm_analysis_port#(sequence_item) rx_mac_input_monitor_predictor_port;  							//---------- ANALYSIS PORT FOR INPUT MONITOR

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "master_driver",uvm_component parent);
		super.new(name,parent);
		rx_mac_input_monitor_predictor_port = new("rx_mac_input_monitor_predictor_port",this);
		
	endfunction

	///////////////////////////////////////////////////////////////////
	// IN RUN PHASE WE HAVE TO DRIVE THE SIGNALS ON TO THE INTERFACE //
	///////////////////////////////////////////////////////////////////


	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		req = sequence_item::type_id::create("req");		//--- OBJECT CREATION FOR SEQUENCE ITEM
		
		func_states;
		monitor;
	endtask

	//////////////////////////////////////////////////////////////
	//  TASK TO WRITE THE APB BASED DRIVING ON TO THE INTERFACE //
	//////////////////////////////////////////////////////////////
	
	task func_states();
		@(h_intf.cb_master_driver) h_intf.cb_master_driver.prstn_i		<=0;
		@(h_intf.cb_master_driver) h_intf.cb_master_driver.psel_i		<=0;
		@(h_intf.cb_master_driver) h_intf.cb_master_driver.penable_i	<=0;
		@(h_intf.cb_master_driver) h_intf.cb_master_driver.pwrite_i 	<=0;
		@(h_intf.cb_master_driver) h_intf.cb_master_driver.paddr_i 		<=0;
		@(h_intf.cb_master_driver) h_intf.cb_master_driver.prstn_i		<=1;
		fork//{			
		forever 
			begin
			seq_item_port.get_next_item(req);
				// IDLE STATE 
				@(h_intf.cb_master_driver)	
				h_intf.cb_master_driver.psel_i		<=0;
				h_intf.cb_master_driver.penable_i	<=0;

				@(h_intf.cb_master_driver)			
			
				//Setup State of APB -  SEL 1, EN 0

				h_intf.cb_master_driver.psel_i		<=	1;
				h_intf.cb_master_driver.penable_i	<=	0;
				h_intf.cb_master_driver.pwrite_i	<=	req.pwrite_i;		//Driving the Remaining Randomized signals
				h_intf.cb_master_driver.paddr_i		<=	req.paddr_i;
				h_intf.cb_master_driver.pwdata_i	<=	req.pwdata_i;
				//Access State of APB - SEL 1, EN 1				
				@(h_intf.cb_master_driver);			
				h_intf.cb_master_driver.psel_i		<=	1;
				h_intf.cb_master_driver.penable_i	<=	1;					
				h_intf.cb_master_driver.pwrite_i	<=	req.pwrite_i;		//Driving the Remaining Randomized signals
				h_intf.cb_master_driver.paddr_i		<=	req.paddr_i;
				h_intf.cb_master_driver.pwdata_i	<=	req.pwdata_i;
			

				wait(h_intf.cb_master_driver.pready_o==1)				
				h_intf.cb_master_driver.penable_i	<=	0;					//Driving Enable 0
			seq_item_port.item_done();	
			end

		forever
		begin
			@(h_intf.cb_master_driver)
			wait(h_intf.cb_master_driver.int_o)
			h_intf.cb_master_driver.psel_i<=1;
			h_intf.cb_master_driver.penable_i<=1;
	 		h_intf.cb_master_driver.pwrite_i<=0;
			h_intf.cb_master_driver.paddr_i<=32'h4;			
			h_intf.cb_master_driver.pwdata_i<=32'h0000_000f;

			wait(h_intf.cb_master_driver.pready_o==1)				
			h_intf.cb_master_driver.penable_i	<=	0;					//Driving Enable 0

		end
	    join //}
	endtask	

	/////////////////////////////////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS AND GETTING THE INTERFACE   //
	//                           AND CONFIG CLASS                              //
	/////////////////////////////////////////////////////////////////////////////
  
  	function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);	
		assert(uvm_config_db#(config_class)::get(null,"*","ethernet_config_class",h_config));	//--- GETTING CONFIG CLASS FROM TOP
    	assert(uvm_config_db#(virtual intf)::get(null,"*","ethernet_interface",h_intf));		//--- GETTING INTERFACE FROM TOP
  	endfunction

	task monitor;
		forever @(h_intf.cb_master_monitor) begin

			
			req.psel_i = h_intf.cb_master_monitor.psel_i;    								//--------- MRxDV VALUE IS TAKING FROM INTERFACE

        	req.penable_i = h_intf.cb_master_monitor.penable_i;        								//--------- MRxD VALUE IS TAKING FROM INTERFACE

        	req.pwrite_i = h_intf.cb_master_monitor.pwrite_i;  								//--------- MRxErr VALUE IS TAKING FROM INTERFACE
			
			req.pwdata_i = h_intf.cb_master_monitor.pwdata_i;  									//--------- MCrS VALUE IS TAKING FROM INTERFACE
			req.paddr_i = h_intf.cb_master_monitor.paddr_i;  									//--------- MCrS VALUE IS TAKING FROM INTERFACE
			req.prdata_o = h_intf.cb_master_monitor.prdata_o;  									//--------- MCrS VALUE IS TAKING FROM INTERFACE
			//r_data = req.prdata_o;
//$display($time,"reset=%d | psel=%d | penable=%d | paddr=%d | pwdata=%d |pready=%d |prdata=%d |pwrite_i =%d",	h_intf.cb_master_monitor.prstn_i,h_intf.cb_master_monitor.psel_i,h_intf.cb_master_monitor.penable_i,h_intf.cb_master_monitor.paddr_i,h_intf.cb_master_monitor.pwdata_i,h_intf.cb_master_monitor.pready_o,h_intf.cb_master_monitor.prdata_o,h_intf.cb_master_monitor.pwrite_i);
			
				rx_mac_input_monitor_predictor_port.write(req);

         
		end
	endtask

endclass
