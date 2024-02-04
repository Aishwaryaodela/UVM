	class reg2ethernet_adapter extends uvm_reg_adapter;

		`uvm_object_utils(reg2ethernet_adapter)		//------ FACTORY REGISTRATION

		function new(string name = "reg2ethernet_adapter");
			super.new(name);
		endfunction

		virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
			sequence_item req = sequence_item::type_id::create("req");
			req.pwrite_i = (rw.kind == UVM_READ)? 0 :1;
			req.paddr_i = rw.addr;
			if(req.pwrite_i) req.pwdata_i = rw.data;
			if(!req.pwrite_i) req.prdata_o = rw.data;

			//if(req.pwrite_i) $display($time,"[Adapter: reg2bus] WR: Addr = %0d, Data = %0d",req.paddr_i,req.pwdata_i);
			//if(!req.pwrite_i) $display($time,"[Adapter: reg2bus] RD: Addr = %0d",req.paddr_i);
			return req;
		endfunction

		virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
			sequence_item req;
			if(!$cast(req,bus_item))begin
				`uvm_fatal("NOT_ETHERNET_TYPE","PROVIDED BUS_ITEM IS NOT OF THE CORRECT TYPE");
				return;
			end
			rw.kind = req.pwrite_i ? UVM_WRITE : UVM_READ;
			rw.addr = req.paddr_i;
			rw.data = req.prdata_o;
			//if(rw.kind == UVM_READ) $display($time,"[Adapter: bus2reg] RD: Addr = %0d, Data = %0d",req.paddr_i,req.prdata_o);
			rw.status = UVM_IS_OK;

	endfunction
	endclass
