
	//////////////////////////////////////////////////////////////////////////////////
	//          IN THIS INTERFACE WE HAVE TO DECLARE ALL THE SIGNALS                // 
	// AND WRITE THE CLOCKING BLOCKS TO AVOID RACING CONDITIONS BETWEEN DUT AND TB	//
	//////////////////////////////////////////////////////////////////////////////////

interface intf(input pclk_i,MRxClk);

	////////////////////////////////////////
	//     INPUTS AND OUTPUTS OF HOST     // 
	////////////////////////////////////////
	
	logic prstn_i;
	logic [31:0] paddr_i;
	logic [31:0] pwdata_i;
	logic [31:0] prdata_o;
	logic psel_i;
	logic pwrite_i;
	logic penable_i;
	logic pready_o;
	
	logic int_o;

	///////////////////////////////////////////
	//      INPUTS AND OUTPUTS OF MEMORY     //
	///////////////////////////////////////////

	logic [31:0] m_paddr_o;
	logic [31:0] m_prdata_i;
	logic [31:0] m_pwdata_o;
	logic m_psel_o;
	logic m_pwrite_o;
	logic m_penable_o;
	logic m_pready_i;

	///////////////////////////////////////
	//     INPUTS AND OUTPUTS OF MAC     //
	///////////////////////////////////////

	logic MRxDV;
	logic [3:0] MRxD;
	logic MRxErr;
	logic MCrS;

	///////////////////////////////////////////
	//     INPUTS AND OUTPUTS FOR TX MAC     //
	///////////////////////////////////////////

	logic MTxClk;
	logic MTxEn;
	logic MTxErr;
	logic [3:0]MTxD;

	//////////////////////////////////////////////
	//     CLOCKING BLOCK FOR MASTER DRIVER     //
	//////////////////////////////////////////////
	
	clocking cb_master_driver @(posedge pclk_i);
		input pready_o,prdata_o,int_o;
		output prstn_i,paddr_i,pwdata_i,psel_i,pwrite_i,penable_i;
	endclocking

	///////////////////////////////////////////////
	//     CLOCKING BLOCK FOR MASTER MONITOR     //
	///////////////////////////////////////////////

	clocking cb_master_monitor @(posedge pclk_i);
		input pready_o,prdata_o,int_o,prstn_i,paddr_i,pwdata_i,psel_i,pwrite_i,penable_i;
	endclocking

	/////////////////////////////////////////////
	//     CLOCKING BLOCK FOR SLAVE DRIVER     //
	/////////////////////////////////////////////

	clocking cb_slave_driver @(posedge pclk_i);
		output m_pready_i,m_prdata_i,prstn_i;
		input m_paddr_o,m_pwdata_o,m_psel_o,m_pwrite_o,m_penable_o,int_o;
	endclocking

	///////////////////////////////////////////////
	//      CLOCKING BLOCK FOR SLAVE MONITOR     //
	///////////////////////////////////////////////

	clocking cb_slave_monitor @(posedge pclk_i);
		input m_pready_i,m_prdata_i,prstn_i,m_paddr_o,m_pwdata_o,m_psel_o,m_pwrite_o,m_penable_o,int_o;
	endclocking

	//////////////////////////////////////////////
	//     CLOCKING BLOCK FOR RX MAC DRIVER     //
	//////////////////////////////////////////////

	clocking  cb_rx_mac_driver @(posedge MRxClk);
		output MRxDV,MRxD,MRxErr,MCrS;
	endclocking

	///////////////////////////////////////////////
	//     CLOCKING BLOCK FOR RX MAC MONITOR     //
	///////////////////////////////////////////////

	clocking cb_rx_mac_monitor@(posedge MRxClk);
		input MRxDV,MRxD,MRxErr,MCrS;
	endclocking

endinterface
