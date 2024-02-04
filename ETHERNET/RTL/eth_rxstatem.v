//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:40:26 06/07/2020 
// Design Name: 
// Module Name:    eth_rxstatem 
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
module eth_rxstatem (MRxClk, Resetn, MRxDV,No_Preamble, Rx_NibCnt,ByteCnt,Frame_drop, ByteCntEq0, ByteCntGreat2, Transmitting, MRxDEq5, MRxDEqD, 
                     IFGCounterEq24, ByteCntMaxFrame, StateData, StateIdle, StatePreamble, StateSFD, StateDA, StateSA,
					 StateLength, StateDrop, rxabort_statedrop
                    );

input         MRxClk;
input         Resetn;
input         MRxDV;
input 		  No_Preamble;
input 		  Rx_NibCnt;
input [15:0]  ByteCnt;
input 		  Frame_drop;
input         ByteCntEq0;
input         ByteCntGreat2;
input         MRxDEq5;
input         Transmitting;
input         MRxDEqD;
input         IFGCounterEq24;
input         ByteCntMaxFrame;

output [1:0]  StateData;
output        StateIdle;
output        StateDrop;
output        StatePreamble;
output        StateSFD;
output		  StateDA;
output		  StateSA;
output 		  StateLength;
reg [3:0] state_rx;
output reg rxabort_statedrop;
localparam STATE_DROP = 1,STATE_IDLE = 2, STATE_PREAMBLE = 3,STATE_SFD = 4, STATE_DA = 5, STATE_SA = 6,
		  STATE_LENGTH = 7, STATE_DATA0 = 8,STATE_DATA1 = 9;

wire           StateData0 	= (state_rx == STATE_DATA0);
wire           StateData1 	= (state_rx == STATE_DATA1);
wire           StateIdle  	= (state_rx == STATE_IDLE);
wire           StateDrop  	= (state_rx == STATE_DROP);
wire           StatePreamble= (state_rx == STATE_PREAMBLE);
wire           StateSFD		= (state_rx == STATE_SFD);
wire 		   StateDA		= (state_rx == STATE_DA);
wire 		   StateSA		= (state_rx == STATE_SA);
wire 		   StateLength	= (state_rx == STATE_LENGTH);


wire          StartIdle;
wire          StartDrop;
wire          StartData0;
wire          StartData1;
wire          StartPreamble;
reg           StartSFD;
wire 		  StartDA;
wire 		  StartSA;
wire 		  StartLength;

// Defining the next state
assign StartIdle = ~MRxDV & ((state_rx ==STATE_DROP) | (state_rx == STATE_PREAMBLE) | (state_rx == STATE_SFD) |(state_rx == STATE_DA)|(state_rx == STATE_SA)|(state_rx == STATE_LENGTH)|(|StateData))  ;

assign StartPreamble = MRxDV & MRxDEq5 & ((state_rx == STATE_IDLE) & ~Transmitting) & ~No_Preamble & IFGCounterEq24;

always@(*)
begin
	if(~No_Preamble)
		StartSFD = MRxDV &((state_rx == STATE_PREAMBLE)& ByteCnt == 'd13);
	else
		StartSFD = MRxDV & MRxDEq5 & ((state_rx == STATE_IDLE) & ~Transmitting) & IFGCounterEq24; 
end

assign StartDA = MRxDV & ((state_rx == STATE_SFD)& ByteCnt == 1);

assign StartSA = MRxDV & ((state_rx == STATE_DA) & ByteCnt == 'd5 & Rx_NibCnt == 'd1);

assign StartLength = MRxDV & ((state_rx == STATE_SA) & Rx_NibCnt == 'd1 & ByteCnt == 'd5);

assign StartData0 = MRxDV & (((state_rx == STATE_LENGTH) & Rx_NibCnt == 'd1 & ByteCnt == 'd1)| (state_rx ==STATE_DATA1));

assign StartData1 = MRxDV & (state_rx == STATE_DATA0) & (~ByteCntMaxFrame);

				  
//Before StateSFD(5d) we are checking Interframegap. 
assign StartDrop = MRxDV & ((state_rx == STATE_IDLE) & Transmitting | (state_rx == STATE_IDLE | state_rx == STATE_PREAMBLE)& ~IFGCounterEq24 &
                  MRxDEqD | (state_rx == STATE_DATA0) &  ByteCntMaxFrame | Frame_drop);

//RX state machine

always@(posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin	
		state_rx <= STATE_DROP;
		rxabort_statedrop <= 1'b0;
	end
  else
  begin
	case(state_rx)
	STATE_DROP : begin	
						rxabort_statedrop <= 1'b0;
					if(StartIdle) begin
						state_rx <= STATE_IDLE;
						end
				  end
	STATE_IDLE : begin
					if(StartDrop)
						state_rx <= STATE_DROP;
					else
					begin
						if(StartPreamble)
							state_rx <= STATE_PREAMBLE;
						else
							if(StartSFD)
								state_rx <= STATE_SFD;
					end
				 end
	STATE_PREAMBLE: begin
						if(StartDrop) begin
							state_rx <= STATE_DROP;
							rxabort_statedrop <= 1'b1;
							end
						else
						begin
							if(StartIdle) 
								state_rx <= STATE_IDLE;
							else
								if(StartSFD)
									state_rx <= STATE_SFD;
						end
					end
	STATE_SFD : begin
					if(StartDrop)
						state_rx <= STATE_DROP;
					else
					begin
						if(StartIdle)
							state_rx <= STATE_IDLE;
						else
						begin
							if(StartDA)
								state_rx <= STATE_DA;
						end
					end
				end
	STATE_DA : begin
				if(StartDrop)
						state_rx <= STATE_DROP;
				else
				begin
					if(StartSA)
						state_rx <= STATE_SA;
				end
			   end
	STATE_SA : begin
				if(StartDrop)
						state_rx <= STATE_DROP;
				else
				begin
					if(StartLength)
						state_rx <= STATE_LENGTH;
				end
			   end
	STATE_LENGTH : begin
					if(StartDrop)
						state_rx <= STATE_DROP;
					else
					begin
					  if(StartData0)
						state_rx <= STATE_DATA0;
					end
				   end
	STATE_DATA0 : begin
					if(StartDrop)
						state_rx <= STATE_DROP;
					else
					begin
						if(StartIdle)
							state_rx <= STATE_IDLE;
						else 
							if(StartData1)
							state_rx <= STATE_DATA1;
					end
				  end
	STATE_DATA1: begin
					if(StartIdle)
						state_rx <= STATE_IDLE;
					else
						if(StartData0)
							state_rx <= STATE_DATA0;
				 end
	endcase
  end
end

assign StateData[1:0] = {(state_rx == STATE_DATA1), (state_rx == STATE_DATA0)};


endmodule

