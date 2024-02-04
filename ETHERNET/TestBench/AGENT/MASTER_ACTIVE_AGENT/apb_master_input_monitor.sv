	///////////////////////////////////////////////////////////////////////
	//  IN THIS RX MONITOR CLASS WE HAVE TO COLLECT THE PACKET GENERATED //
	//   	BY RX MAC SEQUENCE AND COMPARE  WITH THE GENERATED PACKET    //
	///////////////////////////////////////////////////////////////////////


class apb_master_input_monitor extends uvm_monitor;											
	`uvm_component_utils(apb_master_input_monitor)     											//---------- FACTORY REGISTRATION
  	uvm_analysis_port#(sequence_item) rx_mac_input_monitor_predictor_port;  							//---------- ANALYSIS PORT FOR INPUT MONITOR

	sequence_item req;   																	//---------- HANDLE DECLARATION FOR SEQUENCE ITEM 
	virtual intf h_intf;   																	//---------- HANDLE DECLARATION FOR INTERFACE

	config_class h_config;																	//---------- HANDLE DECLARATION FOR CONFIG CLASS

 	//===================================================================
				//read_data r_data;
	//===================================================================

	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "apb_master_input_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
  	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	//                          AND ANALYSIS PORTS                        //
	////////////////////////////////////////////////////////////////////////

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		rx_mac_input_monitor_predictor_port = new("rx_mac_input_monitor_predictor_port",this);
	endfunction
  
 	/////////////////////////////////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS AND GETTING THE INTERFACE   //
	//                           AND CONFIG CLASS                              //
	/////////////////////////////////////////////////////////////////////////////
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      	assert(uvm_config_db#(virtual intf)::get(null,this.get_full_name,"ethernet_interface",h_intf));            	//---- GETTING INTERFACE FROM TOP
		assert(uvm_config_db#(config_class)::get(null,this.get_full_name,"ethernet_config_class",h_config));		//---- GETTING CONFIG CLASS FROM TOP
	endfunction

	/////////////////////////////////////////////////////////////////
	//       IN RUN PHASE WE HAVE TO GET THE INTERFACE SIGNALS     //
	//                 AND WRITE CHECKS TO THEM                    //
	/////////////////////////////////////////////////////////////////

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		req = sequence_item::type_id::create("req");    									//--------- OBJECT CREATION FOR SEQUENCE ITEM

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
