//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:24 06/07/2020 
// Design Name: 
// Module Name:    apb_BDs_bridge 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module apb_BDs_bridge(

//apb signals
input apb_pclk_i,
input apb_presetn_i,
input apb_psel_i,
input apb_penable_i,
input apb_pwrite_i,
input [31:0]apb_pwdata_i,
input [31:0]apb_paddr_i,
output reg [31:0]apb_prdata_o,	
output reg apb_pready_o,	



//wishbone signals
output reg wb_psel_o,
output reg wb_penable_o,
output reg wb_pwrite_o,
output reg [31:0]wb_pwdata_o,
output reg [31:0]wb_paddr_o,
input [31:0]wb_prdata_i,
input wb_BDAck_i
);
localparam IDLE =0,WB_BUSY=1;
reg state;
wire apb_valid_txn;
reg wb_psel_o_next;
reg wb_penable_o_next;
reg wb_pwrite_o_next;
reg [31:0]wb_pwdata_o_next;
reg [31:0]wb_paddr_o_next;

assign  apb_valid_txn =  apb_psel_i & apb_penable_i  & ~apb_paddr_i[11] &  apb_paddr_i[10];   // 0x400 - 0x7FF



always@(posedge apb_pclk_i or negedge apb_presetn_i)
begin
  //$display($time,"------after clk-pwrite =%d",apb_pwrite_i);

  if(apb_presetn_i ==0)begin
    state <= IDLE;  //$display($time,"------reset 0-pwrite =%d",apb_pwrite_i);
end
 else 
  begin
   case(state)
     IDLE:begin     //$display($time,"========first==idle state=valid txn =%d",apb_valid_txn);
       state <= apb_valid_txn ? WB_BUSY:IDLE;end
     WB_BUSY : begin state <= wb_BDAck_i ? IDLE:WB_BUSY;//$display($time,"========first==wb_busy state=valid txn =%d wb_BDAck_i = %d",apb_valid_txn,wb_BDAck_i);
     end
   endcase
  end
end


//NOTE: apb_pready_o generation: when ever psel = 1,penable = 1, wishbone_address and other control signals are available make apb_pready_o = 1
always @(*)
begin
  //$display($time,"=========above case==valid txn =%d",apb_valid_txn);
   case(state)
     IDLE: begin 
       //$display($time,"------idle state-pwrite =%d",apb_pwrite_i);
	        if(apb_pwrite_i)	
				apb_pready_o = apb_valid_txn?1'b1:1'b0;
			else
				apb_pready_o = 1'b0;
		   end
	 WB_BUSY: begin 
				if(wb_pwrite_o)			//Note: In this state signals should not depend on primary input, instead depend on the flop output(wb_pwrite_o). Because primary i/p can be chaanged by the apb master even the state=WB_BUSY.
					apb_pready_o = 1'b0;
				else
					apb_pready_o = wb_BDAck_i?1'b1:1'b0;
			  end
   endcase
end

//apb_prdata_o generation
always @(*)
begin
   case(state)
     IDLE: begin
			  apb_prdata_o = 'dz;
		   end
	 WB_BUSY: begin
				apb_prdata_o = apb_pready_o?wb_prdata_i:'dz;
			  end
   endcase

end

//Wishbone signals generation

always @(posedge apb_pclk_i or negedge apb_presetn_i)
begin
  if(apb_presetn_i == 0)
    wb_psel_o <= 1'b0;
  else 
    wb_psel_o <= wb_psel_o_next;
end
always @(*)
    begin
	  case(state)
	    IDLE: begin 
				if(apb_pwrite_i)
					wb_psel_o_next = apb_pready_o?apb_psel_i:wb_psel_o;
				else
					wb_psel_o_next = apb_psel_i;
			  end
		WB_BUSY: begin 
					if(wb_pwrite_o)				//Note: In this state signals should not depend on primary input, instead depend on the flop output(wb_pwrite_o). Because primary i/p can be chaanged by the apb master even the state=WB_BUSY.
						wb_psel_o_next = wb_BDAck_i?1'b0:wb_psel_o;	
					else
						wb_psel_o_next = apb_psel_i;
				 end
	  endcase
	end

always @(posedge apb_pclk_i or negedge apb_presetn_i)
begin
  if(apb_presetn_i == 0)
    wb_penable_o <= 1'b0;
  else 
	wb_penable_o <= wb_penable_o_next;
end	

always@(*)
    begin
	  case(state)
	    IDLE: begin 
				if(apb_pwrite_i)
					wb_penable_o_next = apb_pready_o?apb_penable_i:wb_penable_o;
				else
					wb_penable_o_next = apb_penable_i;
			  end
		WB_BUSY: begin 
					if(wb_pwrite_o)				//Note: In this state signals should not depend on primary input, instead depend on the flop output(wb_pwrite_o). Because primary i/p can be chaanged by the apb master even the state=WB_BUSY.
						wb_penable_o_next = wb_BDAck_i?1'b0:wb_penable_o;	
					else
						wb_penable_o_next = apb_penable_i;
				 end
	  endcase
	end


always @(posedge apb_pclk_i or negedge apb_presetn_i)
begin
  if(apb_presetn_i == 0)
    wb_pwrite_o <= 1'b0;
  else 
    wb_pwrite_o <= wb_pwrite_o_next;
 end
 
 always@(*)
    begin
	  case(state)
	    IDLE: begin 
				if(apb_pwrite_i)
					wb_pwrite_o_next = apb_pready_o?apb_pwrite_i:wb_pwrite_o;
				else
					wb_pwrite_o_next = apb_pwrite_i;
			  end
		WB_BUSY: begin 
					if(wb_pwrite_o)				///Note: In this state signals should not depend on primary input, instead depend on the flop output(wb_pwrite_o). Because primary i/p can be chaanged by the apb master even the state=WB_BUSY.
						wb_pwrite_o_next = wb_BDAck_i?1'b0:wb_pwrite_o;
					else
						wb_pwrite_o_next = apb_pwrite_i;
				end
	  endcase
	end


always @(posedge apb_pclk_i or negedge apb_presetn_i)
begin
  if(apb_presetn_i == 0)
    wb_paddr_o <= 1'b0;
  else 
  wb_paddr_o <= wb_paddr_o_next;
 end
 
 always@(*)
    begin
	  case(state)
	    IDLE:begin 
				if(apb_pwrite_i)
					wb_paddr_o_next = apb_pready_o?apb_paddr_i:wb_paddr_o;	//Note: as wishbone requires only 8-bit[9:2] of address so taking only 8-bits from the apb_address for wb_paddr_o
				else
					wb_paddr_o_next = apb_paddr_i;
			 end
		WB_BUSY: begin 
					if(wb_pwrite_o)			////Note: In this state signals should not depend on primary input, instead depend on the flop output(wb_pwrite_o). Because primary i/p can be chaanged by the apb master even the state=WB_BUSY.
						wb_paddr_o_next = wb_BDAck_i?1'b0:wb_paddr_o;
					else
						wb_paddr_o_next = apb_paddr_i;		
				 end
	  endcase
	end


always @(posedge apb_pclk_i or negedge apb_presetn_i)
begin
  if(apb_presetn_i == 0)
    wb_pwdata_o <= 1'b0;
  else 
    wb_pwdata_o <= wb_pwdata_o_next;
end	
	
always@(*)
    begin
	  case(state)
	    IDLE: begin
				if(apb_pwrite_i)
					wb_pwdata_o_next = apb_pready_o?apb_pwdata_i:wb_pwdata_o;
				else
					wb_pwdata_o_next = apb_pwdata_i;
			  end
		WB_BUSY:begin
					if(wb_pwrite_o)				//Note: In this state signals should not depend on primary input, instead depend on the flop output(wb_pwrite_o). Because primary i/p can be chaanged by the apb master even the state=WB_BUSY.
						wb_pwdata_o_next = wb_BDAck_i?1'b0:wb_pwdata_o;	
					else
						wb_pwdata_o_next = apb_pwdata_i;
				end
	  endcase
	end




endmodule
