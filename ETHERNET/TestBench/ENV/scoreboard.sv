
//////////////////////////////////////////////////////////////////
//      IN SCORE BOARD CLASS WE HAVE TO COMPARE THE VALUES      //
//          WRITTEN FROM INPUT AND OUTPUT MONITORS              //
//////////////////////////////////////////////////////////////////
class rx_scoreboard extends uvm_component;

	`uvm_component_utils(rx_scoreboard)    												//------ FACTORY REGISTRATION

	score_board_payload ip_queue,op_queue; 													//------ HANDLE FOR SEQUENCE ITEM

	`uvm_analysis_imp_decl(_i_mon)														//------ MACRO TO DECLARE AN IMPLEMENTATION PORT TO INPUT MONITOR TO DIFFERENTIATE THE OUTPUT AND INPUT MONITOR

	uvm_analysis_imp_i_mon#(score_board_payload,rx_scoreboard)  rx_score_ip_imp_port;   //------ IMPLEMENTATION PORT FOR INPUT MONITOR

	uvm_analysis_imp#(score_board_payload,rx_scoreboard)  rx_score_op_imp_port;   		//------ IMPLEMENTATION PORT FOR OUTPUT MONITOR

	virtual intf h_intf;     															//------ INSTANCE FOR INTERFACE

	config_class h_config;																//------ HANDLE FOR CONFIG CLASS
	
	//////////////////////////////////////////////////////////////////////////////
	//   NEW CONSTRUCTOR FOR FOR CREATING MEMORY AND POINTING TO THE PARENT     //
	//////////////////////////////////////////////////////////////////////////////
	
	function new(string name = "rx_scoreboard",uvm_component parent);
		super.new(name,parent);
	endfunction

	////////////////////////////////////////////////////////////////////////
	//      IN BUILD PHASE WE HAVE TO CREATE THE MEMORY FOR THE HANDLES   //
	//                          AND ANALYSIS PORTS                        //
	////////////////////////////////////////////////////////////////////////
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		rx_score_ip_imp_port = new("rx_score_ip_imp_port",this);	 					//------ OBJECT CREATION FOR RX SCOREBOARD INPUT IMPL PORT	
		rx_score_op_imp_port = new("rx_score_op_imp_port",this);						//------ OBJECT CREATION FOR RX SCOREBOARD OUTPUT IMPL PORT	
	endfunction

 	/////////////////////////////////////////////////////////////////////////////
	//   IN CONNECT PHASE WE HAVE TO CONNECT PORTS AND GETTING THE INTERFACE   //
	//                           AND CONFIG CLASS                              //
	/////////////////////////////////////////////////////////////////////////////
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		assert(uvm_config_db#(virtual intf)::get(null,this.get_full_name,"ethernet_interface",h_intf));  	//------ GETTING INTERFACE FROM TOP
    	assert(uvm_config_db#(config_class)::get(this,"*","ethernet_config_class",h_config));				//------ GETTING CONFIG CLASS FROM TOP
	endfunction

	//------------- WRITE FUNCTION FOR INPUT MONITOR --------//

	function void write_i_mon(input score_board_payload ip_queue);
		this.ip_queue = ip_queue;																//------ WRITE METHOD FOR GETTING VALUES WRITTEN BY INPUT MONITOR 
	endfunction

	//------------- WRITE FUNCTION FOR OUTPUT MOITOR -------//

	function void write(input score_board_payload op_queue);
		this.op_queue = op_queue;																//------ WRITE METHOD FOR GETTING VALUES WRITTEN BY INPUT MONITOR
	endfunction

 	/////////////////////////////////////////////////////////////////
	//       IN RUN PHASE WE HAVE TO GET THE INTERFACE SIGNALS     //
	//                 AND WRITE CHECKS TO THEM                    //
	/////////////////////////////////////////////////////////////////

	task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				@(h_intf.cb_rx_mac_monitor)
				if(h_config.input_write && h_config.output_write)begin

				if(op_queue == ip_queue) begin    											//------ COMPARISION BETWEEN INPUT MONITOR VALUES AND OUTPUT MONITOR VALUES
				`uvm_info("=input monitor==scoreboard==passed ",$sformatf("=trans1 =%p==\n",ip_queue),UVM_NONE);
				`uvm_info("=design==scoreboard1==passed ",$sformatf("=trans2 =%p==\n",op_queue),UVM_NONE);
				end
				else begin
				`uvm_info("=input monitor==scoreboard==failed ",$sformatf("=trans1 =%p==\n",ip_queue),UVM_NONE);
				`uvm_info("=design==scoreboard1==failed ",$sformatf("=trans2 =%p==\n",op_queue),UVM_NONE);				
				end
			    h_config.queue_payload[h_config.count].delete();
				
				op_queue.delete();
				ip_queue.delete();

			h_config.input_write = 0;
			h_config.output_write = 0;
			end
		end
	endtask
endclass
