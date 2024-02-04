
`include "interface.sv"
`include "assertion.sv";
	///////////////////////////
	//      TOP MODULE       //
	///////////////////////////

module top;
	
	import uvm_pkg::*;				//------ IMPORT PACKAGES 
	import pkg::*;

	bit pclk_i;						//------ DECLARATION OF APB CLOCK

	always #5 pclk_i++; 			//------ GENERATION OF CLOCK FOR HOST AND MEMORY

	bit MRxClk;						//------ DECLARATION OF MAC CLOCK

	always #20 MRxClk++;  			//------ GENERATION OF CLOCK FOR RX MAC 

	config_class h_config;			//------ HANDLE FOR CONFIG CLASS

  	intf h_intf(pclk_i,MRxClk);  	//------ INTERFACE INSTANTIATION

 	///////////////////////////////////
	//       DUT INSTANTIATION       //
	///////////////////////////////////

	eth_top DUT(

				//	APB HOST SIGNALS

				.pclk_i(h_intf.pclk_i),
				.prstn_i(h_intf.prstn_i),
				.pwdata_i(h_intf.pwdata_i),
				.paddr_i(h_intf.paddr_i),
				.psel_i(h_intf.psel_i),
				.pwrite_i(h_intf.pwrite_i),
				.penable_i(h_intf.penable_i),
				.prdata_o(h_intf.prdata_o),
				.pready_o(h_intf.pready_o),
				.int_o(h_intf.int_o),

				//	APB MEMORY SIGNALS

				.m_paddr_o(h_intf.m_paddr_o),
				.m_psel_o(h_intf.m_psel_o),
				.m_pwrite_o(h_intf.m_pwrite_o),
				.m_pwdata_o(h_intf.m_pwdata_o),
				.m_prdata_i(h_intf.m_prdata_i),
				.m_penable_o(h_intf.m_penable_o),
				.m_pready_i(h_intf.m_pready_i),

				//	Rx MAC SIGNALS

				.mrx_clk_pad_i(h_intf.MRxClk),
				.mrxd_pad_i(h_intf.MRxD),
				.mrxdv_pad_i(h_intf.MRxDV),
				.mrxerr_pad_i(h_intf.MRxErr),
				.mcrs_pad_i(h_intf.MCrS),

				//Tx MAC SIGNALS

				.mtx_clk_pad_i(h_intf.MTxClk),
				.mtxd_pad_o(h_intf.MTxD),
				.mtxen_pad_o(h_intf.MTxEn),
				.mtxerr_pad_o(h_intf.MTxErr));

	//////////////////////////////////////////////
	//      ASSERTION BLOCK INSTANTIATION       //
	//////////////////////////////////////////////
	
	/*bind eth_top Ethernet_assertions DSV(
											h_intf.pclk_i,
											h_intf.prstn_i,
											h_intf.pwdata_i,
											h_intf.prdata_o,
											h_intf.paddr_i,
											h_intf.psel_i,
											h_intf.pwrite_i,
											h_intf.penable_i,
											h_intf.pready_o,
											
											h_intf.m_paddr_o,
											h_intf.m_psel_o,
											h_intf.m_pwrite_o,
											h_intf.m_pwdata_o,
											h_intf.m_prdata_i,
											h_intf.m_penable_o,
											h_intf.m_pready_i,
											h_intf.int_o,

											h_intf.MRxClk,
											h_intf.MRxD,
											h_intf.MRxDV,
											h_intf.MRxErr,
											h_intf.MCrS);
*/

	initial 
		begin
	  		h_config = config_class::type_id::create("h_config");
      		uvm_config_db#(virtual intf)::set(null,"*","ethernet_interface",h_intf);    //------------- INTERFACE SETTING 
      		//uvm_config_db#(config_class)::set(null,"uvm_test_top.h_main_env.*","ethernet_config_class",h_config);    //------------- CONFIG CLASS SETTING 
      		uvm_config_db#(config_class)::set(null,"*","ethernet_config_class",h_config);    //------------- CONFIG CLASS SETTING 
      		//uvm_config_db#(config_class)::set(this,"*","ethernet_config_class",h_config);   /*  Unresolved reference to 'this'. */ //------------- CONFIG CLASS SETTING
      		//uvm_config_db#(config_class)::set(this,"uvm_test_top.h_main_env.*","ethernet_config_class",h_config); /*  Unresolved reference to 'this'. */ //------------- CONFIG CLASS SETTING 

	  		run_test();
		end
endmodule

