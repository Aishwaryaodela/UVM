module Ethernet_assertions(
	//APB_master_slave signals
	input   pclk_i,
	input   prstn_i,
	input [31:0] pwdata_i,
	input [31:0]  prdata_o,
	input [31:0]  paddr_i,
	input   psel_i,
	input   pwrite_i,
	input   penable_i,
	input   pready_o,
	input [31:0]  m_paddr_o,
	input   m_psel_o,
	input   m_pwrite_o,
	input [31:0]  m_pwdata_o,
	input [31:0]  m_prdata_i,
	input   m_penable_o,
	input   m_pready_i,
	input   int_o,
	//Ethernet Mac signals
	input   MRxClk,
	input [3:0]  MRxD,
	input   MRxDV,
	input   MRxErr,
	input   MCrS);

	//----property writing for checking APB clock period
	property CLOCK_CHECK;
		real time1, time2;
		@(posedge pclk_i) (1,time1=$realtime) ##1 (1,time2=$realtime) |-> (time2-time1 == 10);//`period);
	endproperty

	//----MRxClk period checking
	property MRxClk_CHECK;
		real time3, time4;
		@(posedge MRxClk) (1,time3=$realtime) ##1 (1,time4=$realtime) |-> (time4-time3 == 40);//`period);
	endproperty

	//-----Reset check
	property RESET_CHECK;
		@(posedge pclk_i) $fell(prstn_i) |-> ($isunknown(prdata_o) && (pready_o) == 0 && (m_paddr_o) == 0 && (m_psel_o) ==0 && (m_pwrite_o) == 0 && $isunknown(m_pwdata_o) && (m_penable_o)==0); 
	endproperty
	
	//-----APB enable checking
	property ENABLE_CHECK;
		@(posedge pclk_i) $rose(psel_i) |-> (penable_i == 0) |=> (penable_i == 1);
	endproperty

	//-----APB Pready check
	property PREADY_CHECK;
		@(posedge pclk_i) $stable(psel_i) |=> $rose(penable_i) |=> (pready_o == 0);
	endproperty
/*
	//-----Pready is 0 check
	property PREADY_0_CHECK;
		@(posedge pclk_i) disable iff(prstn_i) $fell(penable_i) |-> (pready_o == 0);
	endproperty
	*/

	//-----property for stable data checking
	property STABLE_DATA_CHECK;
		@(posedge pclk_i)
										if(psel_i == 1 && penable_i ==1) $stable(pwdata_i);
	endproperty

	//-----checking the pready signal is low when selection is high and penable is also low
	property PREADY_FELL_CHECK;
		@(posedge pclk_i)
										$rose(psel_i) |=> $rose(penable_i) |-> $rose(pready_o);
	endproperty

	//-----"checking when mcrs=0 the pins MRxDV MRxErr are driven high or not and the MRxD is unknown or not"
	property MRxD_CHECK;
		@(posedge MRxClk) MCrS |-> MRxDV |-> (MRxErr == 0) |-> !($isunknown(MRxD));
	endproperty

	//-----m_pready checking when m_psel  and m_penable are high
	property M_PREADY_I_CHECK;
      @(posedge pclk_i) disable iff(prstn_i)  (m_psel_o && m_penable_o)|->m_pready_i ;
	endproperty

/*
	APB_clock_check : assert property (CLOCK_CHECK) $display($time,"<---APB_clock_check---Assertion :: PASS------>");
													else $warning($time,"<---APB_clock_check---FAIL------>");
	
	RX_clock_check : assert property (MRxClk_CHECK) $display($time,"<--RX_clock_check----Assertion :: PASS------>");
													else $warning($time,"<--RX_clock_check----FAIL------>");
	
	Reset_check : assert property (RESET_CHECK) $display($time,"<---Reset_check---Assertion :: PASS------>");
												else $warning($time,"<--Reset_check----FAIL------>");

	APB_enable_check : assert property(ENABLE_CHECK) $display($time,"<--APB_enable_check----Assertion :: PASS------>");
													 else $warning($time,"<--APB_enable_check----FAIL------>");

	APB_pready_check : assert property(PREADY_CHECK) $display($time,"<---APB_pready_check---Assertion :: PASS------>");
													 else $warning($time,"<----APB_pready_check--FAIL------>");

/*	Pready_zero_check : assert property(PREADY_0_CHECK) $display($time,"<------Assertion :: PASS------>");
													 	else $warning($time,"<------FAIL------>");

	data_stable_check : assert property(STABLE_DATA_CHECK) $display($time,"<--data_stable_check----Assertion :: PASS------>");
													 	   else $warning($time,"<--data_stable_check----FAIL------>");
														   
	Pready_fell_check : assert property(PREADY_FELL_CHECK) $display($time,"<---Pready_fell_check---Assertion :: PASS------>");
													 	   else $warning($time,"<---Pready_fell_check---FAIL------>");
	
	MrxD_pin_check : assert property(MRxD_CHECK) $display($time,"<--MrxD_pin_check----Assertion :: PASS------>");
												 else $warning($time,"<---MrxD_pin_check---FAIL------>");
	
	M_pready_i_pin_check : assert property(M_PREADY_I_CHECK) $display($time,"<---M_pready_i_pin_check---Assertion :: PASS------>");
													 		 else $warning($time,"<---M_pready_i_pin_check---FAIL------>");	
*/
endmodule											 
