

class RAL_sequence extends uvm_sequence;

	`uvm_object_utils(RAL_sequence)

	ETHERNET_REG_BLOCK REG_BLOCK;

		uvm_status_e status;

		rand uvm_reg_data_t writing_value;
		bit [31:0] read_store_data;

		int index;
		int RXBD_ADDR;
		int count;
		
		
	config_class h_config;

	function new(string name = "RAL_sequence");
		super.new(name);
         assert(uvm_config_db #(config_class)::get(null,"*","ethernet_config_class",h_config));		
	endfunction

	task body();

		
	
		if (starting_phase != null)
			starting_phase.raise_objection(this);
			REG_BLOCK.map.set_auto_predict(0);

		assert(this.randomize() with {writing_value == {24'd0,h_config.TX_BD_NUM};});

		REG_BLOCK.REG_TX_BD_NUM.write(status,writing_value);//32'd125);
    	REG_BLOCK.REG_TX_BD_NUM.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_TX_BD_NUM.read(status,read_store_data);			//READ 
		

		$display($time,"*******************************TX BD NUM*************************************************\n");
		$display($time,"------status = %0p ------",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d",REG_BLOCK.REG_TX_BD_NUM.get(),REG_BLOCK.REG_TX_BD_NUM.get_mirrored_value(),REG_BLOCK.REG_TX_BD_NUM.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_TX_BD_NUM.get(),REG_BLOCK.REG_TX_BD_NUM.get_mirrored_value());
		$display($time,"********************************************************************************\n");

		assert(this.randomize() with {writing_value == {28'b0,h_config.RXE,h_config.RXB,h_config.TXE,h_config.TXB};});

		REG_BLOCK.REG_INT_SOURCE.write(status,writing_value);
    	REG_BLOCK.REG_INT_SOURCE.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_INT_SOURCE.read(status,read_store_data);			//READ 
		

		$display($time,"*********************************INT SOURCE***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_INT_SOURCE.get(),REG_BLOCK.REG_INT_SOURCE.get_mirrored_value(),REG_BLOCK.REG_INT_SOURCE.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_INT_SOURCE.get(),REG_BLOCK.REG_INT_SOURCE.get_mirrored_value());
		$display($time,"********************************************************************************\n");
		
		assert(this.randomize() with {writing_value == {27'b0,h_config.FIAD};});

		REG_BLOCK.REG_MIIADDRESS.write(status,writing_value);
    	REG_BLOCK.REG_MIIADDRESS.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_MIIADDRESS.read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_MIIADDRESS***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_MIIADDRESS.get(),REG_BLOCK.REG_MIIADDRESS.get_mirrored_value(),REG_BLOCK.REG_MIIADDRESS.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_MIIADDRESS.get(),REG_BLOCK.REG_MIIADDRESS.get_mirrored_value());
		$display($time,"********************************************************************************\n");

		assert(this.randomize() with {writing_value == {h_config.byte_5,h_config.byte_4,h_config.byte_3,h_config.byte_2};});

		REG_BLOCK.REG_MAC_ADDR0.write(status,writing_value);
    	REG_BLOCK.REG_MAC_ADDR0.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_MAC_ADDR0.read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_MAC_ADDR0***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_MAC_ADDR0.get(),REG_BLOCK.REG_MAC_ADDR0.get_mirrored_value(),REG_BLOCK.REG_MAC_ADDR0.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_MAC_ADDR0.get(),REG_BLOCK.REG_MAC_ADDR0.get_mirrored_value());
		$display($time,"********************************************************************************\n");

		assert(this.randomize() with {writing_value == {16'b0,h_config.byte_1,h_config.byte_0};});

		REG_BLOCK.REG_MAC_ADDR1.write(status,writing_value);
    	REG_BLOCK.REG_MAC_ADDR1.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_MAC_ADDR1.read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_MAC_ADDR1***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_MAC_ADDR1.get(),REG_BLOCK.REG_MAC_ADDR1.get_mirrored_value(),REG_BLOCK.REG_MAC_ADDR1.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_MAC_ADDR1.get(),REG_BLOCK.REG_MAC_ADDR1.get_mirrored_value());
		$display($time,"********************************************************************************\n");

		assert(this.randomize() with {writing_value == {28'b0,h_config.RXE_M,h_config.RXB_M,h_config.TXE_M,h_config.TXB_M};});

		REG_BLOCK.REG_INT_MASK.write(status,writing_value);
    	REG_BLOCK.REG_INT_MASK.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_INT_MASK.read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_INT_MASK***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_INT_MASK.get(),REG_BLOCK.REG_INT_MASK.get_mirrored_value(),REG_BLOCK.REG_INT_MASK.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.INT_MASK.get(),REG_BLOCK.INT_MASK.get_mirrored_value());
		$display($time,"********************************************************************************\n");
		
/*		RXBD_ADDR = 1024+(h_config.TX_BD_NUM*8);
		repeat(h_config.RX_BD_NUM)
		begin
		  h_config.LEN = h_config.length_[index];

		assert(this.randomize() with {writing_value == {h_config.LEN,h_config.EMPTY,h_config.IRQ,
										1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,h_config.MISS,1'b0,1'b0,1'b0,h_config.TL,
										1'b0,h_config.CRC,1'b0};});

		REG_BLOCK.REG_RX_OFFSET_0[count].write(status,writing_value);
    	REG_BLOCK.REG_RX_OFFSET_0[count].mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_RX_OFFSET_0[count].read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_RX_OFFSET_0***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_RX_OFFSET_0[count].get(),REG_BLOCK.REG_RX_OFFSET_0[count].get_mirrored_value(),REG_BLOCK.REG_RX_OFFSET_0[count].get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_RX_OFFSET_0.get(),REG_BLOCK.REG_RX_OFFSET_0.get_mirrored_value());
		$display($time,"********************************************************************************\n");

		assert(this.randomize() with {writing_value == {RXBD_ADDR+8};});

		REG_BLOCK.REG_RX_OFFSET_4[count].write(status,writing_value);
    	REG_BLOCK.REG_RX_OFFSET_4[count].mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_RX_OFFSET_4[count].read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_RX_OFFSET_4***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_RX_OFFSET_4[count].get(),REG_BLOCK.REG_RX_OFFSET_4[count].get_mirrored_value(),REG_BLOCK.REG_RX_OFFSET_4[count].get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_RX_OFFSET_4.get(),REG_BLOCK.REG_RX_OFFSET_0.get_mirrored_value());
		$display($time,"********************************************************************************\n");

		index++; 
		count++;
	  	end
*/
		assert(this.randomize() with {writing_value == {16'b0,h_config.PAD,h_config.HUGEN,1'b0,1'b0,1'b0,h_config.FULLD,
	  								1'b0,1'b0,h_config.LOOPBCK,h_config.IFG,h_config.PRO,1'b0,h_config.BRO,h_config.NOPRE,h_config.TXEN,
										h_config.RXEN};});

		REG_BLOCK.REG_MODER.write(status,writing_value);
    	REG_BLOCK.REG_MODER.mirror(status, UVM_CHECK);	//MIRROR
    	REG_BLOCK.REG_MODER.read(status,read_store_data);			//READ 
		

		$display($time,"*********************************REG_MODER***********************************************\n");
		$display($time,"------status = %0p ------\n",status);
		`uvm_info(get_type_name(), $sformatf("WRITE desired = %0d \t mirrored = %0d \t reset = %0d\n",REG_BLOCK.REG_MODER.get(),REG_BLOCK.REG_MODER.get_mirrored_value(),REG_BLOCK.REG_MODER.get_reset()), UVM_MEDIUM)
		//$display($time,"desired value = %0d mirror value = %0d ",REG_BLOCK.REG_MODER.get(),REG_BLOCK.REG_MODER.get_mirrored_value());
		$display($time,"********************************************************************************\n");




		if (starting_phase != null)
			starting_phase.drop_objection(this);

	endtask
endclass	
