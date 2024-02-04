
class coverage extends uvm_component;

	`uvm_component_utils(coverage)

	 uvm_analysis_imp #(sequence_item,coverage) cov_imp_port;

	 sequence_item req;

	 virtual intf h_intf;

	
//-------------cover group	
	covergroup c_group;

//========================================================================APB_HOST_SIGNALS========================================================
	
// --------------automatic bin { bins reset1[]={1,0};}	
	RESET: coverpoint req.prstn_i;	
								
// -----------------------conditional bins

	PSEL_WITH_PRESET_0: coverpoint req.psel_i iff(req.prstn_i==0) { bins sel_0[]={0,1};}

// ----------------------------------ignore_bins

	PSEL_WITH_PRESET_1: coverpoint req.psel_i iff(req.prstn_i==1) { ignore_bins sel_1[]={0,1};} 		
									
//------------------------dynamic explicit bins

	PENABLE_WITH_PRESET_0:coverpoint req.penable_i iff(req.prstn_i==0){ bins enable_0[]={0,1};}

//------------------------------ignore_bins

	PENABLE_WITH_PRESET_1:coverpoint req.penable_i iff(req.prstn_i==1){ bins enable_1[]={0,1};}


//------------------------dynamic explicit bins

	VALID_WRITE_PRESET_0:coverpoint req.pwrite_i iff(req.prstn_i==0){ bins wr_0[]={0,1};}

//-----------------------ignore bins

	VALID_WRITE_PRESET_1:coverpoint req.pwrite_i iff(req.prstn_i==0){ ignore_bins wr_1[]={0,1};}

//---------------------------------transitions bins

	VALID_SEL_RESET_0:coverpoint req.psel_i iff(req.prstn_i==0) { bins sel1=(0=>1); 
								      bins sel2=(1=>1);
								      bins sel3=(1=>0);
							              bins rep_psel = (1 [* 3:5]);}

//---------------------------------transitions bins with ignore bins------------

	VALID_SEL_RESET_1:coverpoint req.psel_i iff(req.prstn_i==1) { ignore_bins inv_sel1=(0=>1); 
								      ignore_bins inv_sel2=(1=>1);
								      ignore_bins inv_sel3=(1=>0);
							              ignore_bins inv_rep_psel = (1 [* 3:5]);}

//---------------------------------transitions bins

	VALID_ENABLE_RESET_0:coverpoint req.penable_i iff(req.prstn_i==0) { bins sel1=(0=>1); 
								      bins sel2=(1=>1);
								      bins sel3=(1=>0);
							              bins rep_psel = (1 [* 3:5]);}

//---------------------------------transitions bins with ignore bins------------

	VALID_ENABLE_RESET_1:coverpoint req.penable_i iff(req.prstn_i==1) { ignore_bins inv_sel1=(0=>1); 
								      ignore_bins inv_sel2=(1=>1);
								      ignore_bins inv_sel3=(1=>0);
							              ignore_bins inv_rep_psel= (1 [* 3:5]);}
	

//---------------------------cross cover bins

	COMB1: cross  req.prstn_i,req.psel_i,req.penable_i,req.pwrite_i;

//--------------------------------- mutli width bins -----------------------

	ADDR:coverpoint  req.paddr_i iff(req.prstn_i==0){bins Paddr_reg[7]={'h00 , 'h04, 'h08, 'h20, 'h30, 'h40, 'h44};}

	M_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h00)     {bins moder_data[50] = {[0 :49263]};}

	INT_S_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h04)  {bins int_s_data[3] = {[0 :15]};}

	INT_M_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h08)  {bins int_s_data[3] = {[0 :15]};}
	
	TX_BD_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h20)  {bins tx_bd_data[10] = {[0 :255]};}

	MII_ADDR_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h30) {bins mii_add_data[10] = {[0 :31]};}

	MAC_ADDR0_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h40) {bins mac_addr0_data[50] = {[0 :4294967295]};}

	MAC_ADDR1_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h44) {bins mac_addr1_data[50] = {[0 :65535]};}

//--------------------------------------transition bins

	TRANS_M_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h00)     {bins moder_b1 = ( 0 => 49153);
												bins moder_b2 = ( 49153 => 49263);}

	TRANS_INT_S_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h04)  {bins int_s_b1 = ( 0 => 7);
												bins int_s_b2 = ( 7 => 15);}

	TRANS_INT_M_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h08)  {bins int_m_b1 = ( 0 => 7);
												bins int_m_b2 = ( 7 => 15);}
	
	TRANS_TX_BD_CONFIG_FIELDS:coverpoint req.pwdata_i iff(req.prstn_i == 0 && req.paddr_i=='h20)  {bins tx_bd_b1 = ( 0 => 128);
												bins tx_bd_b2 = ( 128 => 200);
												bins tx_bd_b3 = ( 200 => 255);}

//=============================================================APB_MEMORY_SIGNALS========================================================
	
	MASTER_PREADY:coverpoint req.m_pready_i iff(req.prstn_i == 0) {bins pready_m1 = {0};
							  bins pready_m2 = {1};}
	
	READ_DATA_IN:coverpoint req.m_prdata_i iff(req.prstn_i == 0) {bins prdata_1[1000] = {[0:4294967295]};}


//===============================================================MAC RX INTERFACE+================================================	

	MAC_RXDV:coverpoint req.MRxDV iff(req.prstn_i == 0) {bins mrxd [] = {0,1};}
	
	MAC_RXERR:coverpoint req.MRxErr iff(req.prstn_i == 0) {bins mrxerr [] = {0,1};}

	MAC_CARRIER_SENSE:coverpoint  req.MCrS iff(req.prstn_i == 0) {bins mcrs[] = {0,1};}


//----------------------------------------------cross bins-----------------------------------

	COMB_2: cross   req.MRxDV,req.MRxErr,req.MCrS;

//-----------------------------------mutli width bins----------------------------	
	MAC_IN_DATA:coverpoint req.MRxD iff(  req.prstn_i == 0 && req.MRxDV)  {wildcard bins data_in [16] = {4'b????};} // wild card bin

	endgroup
//---------------constructor----------------------
	function new(string name ="coverage",uvm_component parent);
		super.new(name,parent);
		cov_imp_port= new("cov_imp_port",this);
		c_group=new();
	$display("coverageclass");

	endfunction
//-----------------------------build_phase-----------------------
function void build_phase(uvm_phase phase);

		super.build_phase(phase);
		req = sequence_item :: type_id :: create ("req");

		assert(uvm_config_db #(virtual intf)::get(this,"*","ethernet_interface",h_intf));

	endfunction

//------------------write methode

function  void write(input sequence_item req);
		this.req=req;
		c_group.sample();
		endfunction

endclass



