//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:39:07 06/07/2020 
// Design Name: 
// Module Name:    eth_rxaddrcheck 
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

`include "timescale.v"
module eth_rxaddrcheck(MRxClk,  Resetn, MRxD,LatchedByte ,r_Bro ,r_Pro,r_Iam,Rx_NibCnt,
                       ByteCntEq0,ByteCntEq1,ByteCntEq2, ByteCntEq3, ByteCntEq4, 
					   ByteCntEq5,ByteCntEq6, ByteCntEq7, HASH0, HASH1, 
                       CrcHash,    CrcHashGood, StateDA,StateSFD,StateIdle,StateDrop ,RxEndFrm,
                       MAC, Address_mismatch, AddressMiss, PassAll,RxAddressInvalid,
                       ControlFrmAddressOK
                      );


  input        MRxClk; 
  input        Resetn; 
  input [7:0]  LatchedByte;
  input [3:0]  MRxD; 
  input 	   Rx_NibCnt;
  input        r_Bro; 
  input        r_Pro; 
  input 	   r_Iam;
  input        ByteCntEq0;
  input        ByteCntEq1;
  input        ByteCntEq2;
  input        ByteCntEq3;
  input        ByteCntEq4;
  input        ByteCntEq5;
  input        ByteCntEq6;
  input        ByteCntEq7;
  input [31:0] HASH0; 
  input [31:0] HASH1; 
  input [5:0]  CrcHash; 
  input        CrcHashGood;  
  input [47:0] MAC;
  input 	   StateDA;
  input 	   StateSFD;
  input        StateIdle;
  input		   StateDrop;
  input        RxEndFrm;
  input        PassAll;
  input        ControlFrmAddressOK;
  
  output  reg  Address_mismatch;
  output       AddressMiss;
  output  reg  RxAddressInvalid;

 reg BroadcastOK;
 wire ByteCntEq2;
 wire ByteCntEq3;
 wire ByteCntEq4; 
 wire ByteCntEq5;
 reg RxAddressInvalid_next;
 wire HashBit;
 wire [31:0] IntHash;
 reg [7:0]  ByteHash;
 reg MulticastOK;
 reg UnicastOK;
 reg AddressMiss;
 reg Multicast;

function Iamcheck_for_RxAddrInvalid(input reg dummy);
	case(r_Iam)
	1:$display("pending to implement");   
	0:begin
	        case(UnicastOK)
			1:begin
				   case(({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[7:0])
					1:Iamcheck_for_RxAddrInvalid = 'b0;
					0:Iamcheck_for_RxAddrInvalid = 'b1;
					endcase		
			  end
			0:Iamcheck_for_RxAddrInvalid = 'b1;
			endcase
	 end 
	endcase
endfunction


//Note: Adding flop here to avaoid the unwanted(glitches) results , which we are facing with combo
always@(posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0) RxAddressInvalid <= 0;
  else
       RxAddressInvalid <= RxAddressInvalid_next;
end
always@(*)
begin
		if(StateDA && ByteCntEq5 && Rx_NibCnt)
		begin
			case(r_Pro)
			1: RxAddressInvalid_next = 'b0;
			0: begin
					case(r_Bro)
					1:	begin
							case(({LatchedByte[3:0],LatchedByte[7:4]}) == 'hff && BroadcastOK)
							1:begin
								RxAddressInvalid_next = 'b1;
							  end
							0:begin
								RxAddressInvalid_next = Iamcheck_for_RxAddrInvalid(0);
							  end
							endcase
						end
					0:begin
							case(({LatchedByte[3:0],LatchedByte[7:4]}) == 'hff && BroadcastOK)
							1:begin
								RxAddressInvalid_next = 'b0;
							  end
							0:begin
								RxAddressInvalid_next = Iamcheck_for_RxAddrInvalid(0);
							  end
							endcase
					  end
					endcase
			   end
			endcase
		end
		else 
		begin
		     if(RxEndFrm) RxAddressInvalid_next = 0;
			 else         RxAddressInvalid_next = RxAddressInvalid;        
		end
end	


//Note: 1.RxAddressInvalid generation happens, when StateDA & ByteCntEq5
//      2.So Address_mismatch genaration ,no need to dependent on ByteCntEq5 & StateDA  
//      3.Genarting Address_mismatch as a pulse(one clk pulse wide)
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    Address_mismatch <=  1'b0;
  else if(RxAddressInvalid_next & ByteCntEq5 & StateDA)
    Address_mismatch <=  1'b1;
  else
    Address_mismatch <=  1'b0;
end
 

// This ff holds the "Address Miss" information that is written to the RX BD status.
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    AddressMiss <=  1'b0;
  else if(StateIdle & ByteCntEq0)
    AddressMiss <=  1'b0;
  else if(ByteCntEq5 & StateDA)
		AddressMiss <= RxAddressInvalid_next; 
end


// Hash Address Check, Multicast
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    MulticastOK <=  1'b0;
  else if(RxEndFrm)
    MulticastOK <=  1'b0;
  else if(CrcHashGood & Multicast)
    MulticastOK <=  HashBit;
end


 always @ (posedge MRxClk or negedge Resetn)    
begin
  if(Resetn == 0)
    Multicast <=  1'b0;
  else
    begin      
      if((StateDA & Rx_NibCnt == 'd0) & MRxD[0])		
	  begin
			case(1)
			ByteCntEq0: Multicast <=  1'b1;
			endcase
	  end
	  else
      begin 	  
		  if(RxEndFrm)
		  Multicast <=  1'b0;
	  end
    end
end 


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    UnicastOK <=  1'b0;
  else 
  begin
		if(StateDA)
		begin
			case(1)   //Note: 1.In below comparison , need to check Lsb bits first and then check for Msb.
				      //      2.Which is neccessary in order to sync with RXData generation.
					  //      3.RxData will be sent to the RXFIFO.
			ByteCntEq0:begin //47:40
							if(Rx_NibCnt) begin
								UnicastOK  <=  (({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[47:40]); 
							end
					   end 
					   
			ByteCntEq1:begin  // 39:32	
							if(Rx_NibCnt) begin
								UnicastOK  <=  ( ({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[39:32]) && UnicastOK;								
								end
					   end
			ByteCntEq2:begin  // 31:24
							if(Rx_NibCnt) begin
								UnicastOK  <=  ( ({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[31:24]) && UnicastOK;
						end
					   end
			ByteCntEq3:begin  // 23:16
							if(Rx_NibCnt) begin
								UnicastOK  <=  ( ({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[23:16]) && UnicastOK;
							end
					   end
			ByteCntEq4:begin  // 15:8
							if(Rx_NibCnt) begin
								UnicastOK  <=  ( ({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[15:8]) && UnicastOK;
							end
					   end
			ByteCntEq5:begin  // 7:0
							if(Rx_NibCnt) begin
								 UnicastOK  <=  ( ({LatchedByte[3:0],LatchedByte[7:4]}) == MAC[7:0]) && UnicastOK;
							end
					   end
			endcase
		end
		else 
		begin
			if(RxEndFrm)
				UnicastOK  <=  1'b0;
		end
	end
end

always@(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
		BroadcastOK <= 1'b0;
	else
	begin
			if(StateDA)
			begin
				case(1)
				ByteCntEq0 :begin	
								if(Rx_NibCnt)
									BroadcastOK <= LatchedByte[7:0] == 'hff;
							end
				ByteCntEq1,
				ByteCntEq2,
				ByteCntEq3,
				ByteCntEq4,
				ByteCntEq5 :begin	
								if(Rx_NibCnt)
									BroadcastOK <= LatchedByte[7:0] == 'hff && BroadcastOK;
							end
				endcase
			end
			else
			begin
				  if(RxEndFrm)  
					BroadcastOK <= 1'b0;
			end
	end
		
end 
 
assign IntHash = (CrcHash[5])? HASH1 : HASH0;
  
always@(CrcHash or IntHash)
begin
  case(CrcHash[4:3])
    2'b00: ByteHash = IntHash[7:0];
    2'b01: ByteHash = IntHash[15:8];
    2'b10: ByteHash = IntHash[23:16];
    2'b11: ByteHash = IntHash[31:24];
  endcase
end
      
assign HashBit = ByteHash[CrcHash[2:0]];


endmodule

