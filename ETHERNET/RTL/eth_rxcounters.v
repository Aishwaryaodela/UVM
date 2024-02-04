//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:39:27 06/07/2020 
// Design Name: 
// Module Name:    eth_rxcounters 
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
module eth_rxcounters 
  (
   MRxClk, Resetn, MRxDV, StateIdle, StateSFD, StateData, StateDrop, StateSA, StateDA,StateLength, StatePreamble, 
   MRxDEq5, MRxDEqD, DlyCrcEn, DlyCrcCnt, Transmitting, MaxFL, r_IFG, HugEn, IFGCounterEq24, 
   ByteCntEq0, ByteCntEq1, ByteCntEq2,ByteCntEq3,ByteCntEq4,ByteCntEq5, ByteCntEq6,
   ByteCntEq7, ByteCntGreat2, ByteCntSmall7, ByteCntMaxFrame, ByteCntOut, Rx_NibCnt,frame_ByteCnt
   );

input         MRxClk;
input         Resetn;
input         MRxDV;
input         StateSFD;
input [1:0]   StateData;
input 		  MRxDEq5;
input         MRxDEqD;
input         StateIdle;
input         StateDrop;
input         DlyCrcEn;
input         StatePreamble;
input 		  StateDA;
input 		  StateSA;
input 		  StateLength;
input         Transmitting;
input         HugEn;
input [15:0]  MaxFL;
input         r_IFG;

output        IFGCounterEq24;           // IFG counter reaches 9600 ns (960 ns)
output [3:0]  DlyCrcCnt;                // Delayed CRC counter
output        ByteCntEq0;               // Byte counter = 0
output        ByteCntEq1;               // Byte counter = 1
output        ByteCntEq2;               // Byte counter = 2  
output        ByteCntEq3;               // Byte counter = 3  
output        ByteCntEq4;               // Byte counter = 4  
output        ByteCntEq5;               // Byte counter = 5  
output        ByteCntEq6;               // Byte counter = 6
output        ByteCntEq7;               // Byte counter = 7
output        ByteCntGreat2;            // Byte counter > 2
output        ByteCntSmall7;            // Byte counter < 7
output        ByteCntMaxFrame;          // Byte counter = MaxFL
output [15:0] ByteCntOut;               // Byte counter
output 		  Rx_NibCnt;
output [15:0] frame_ByteCnt;

wire          ResetByteCounter;
wire 		  ResetFrameByteCounter;
wire          IncrementByteCounter;
wire          ResetIFGCounter;
wire          IncrementIFGCounter;
wire          ByteCntMax;

reg 		  Rx_NibCnt;
wire 		  Rx_ResetNibCnt;
wire 		  Rx_IncrementNibCnt;

reg   [15:0]  ByteCnt;
reg   [15:0]  frame_ByteCnt;
reg   [3:0]   DlyCrcCnt;
reg   [4:0]   IFGCounter;

wire  [15:0]  ByteCntDelayed;

//Moschip Team
//adding the nibcnt code 

assign Rx_ResetNibCnt = MRxDV & (StateSFD | StateData | (StateDA & Rx_NibCnt == 'd1 & ByteCnt == 'd5) |
						(StateSA & Rx_NibCnt == 'd1 & ByteCnt == 'd5) | (StateLength & Rx_NibCnt == 'd1 & ByteCnt == 'd1));

assign Rx_IncrementNibCnt = ~Rx_ResetNibCnt & MRxDV & (StateDA | StateSA | StateLength);


always @(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
		Rx_NibCnt <= 'd0;
    else
    begin
      if(Rx_ResetNibCnt)
        Rx_NibCnt <= 'd0;
      else
      if(Rx_IncrementNibCnt)
        Rx_NibCnt <=  Rx_NibCnt + 'd1;
    end
end


assign ResetByteCounter = (MRxDV & ((StatePreamble & ByteCnt == 'd13)| (StateSFD &ByteCnt == 1 ) | (StateDA & Rx_NibCnt == 'd1 & ByteCnt == 'd5)|(StateSA & Rx_NibCnt == 'd1 & ByteCnt == 'd5)| 
							(StateLength & Rx_NibCnt == 'd1 & ByteCnt == 'd1)| StateData[1] & ByteCntMaxFrame)) | StateIdle;
							

assign IncrementByteCounter = (~ResetByteCounter & MRxDV & 
                              (StatePreamble | StateSFD | (StateDA & Rx_NibCnt == 'd1) | (StateSA & Rx_NibCnt == 'd1) | (StateLength & Rx_NibCnt == 'd1) |
							  StateIdle & ~Transmitting | StateData[1] & ~ByteCntMax & ~(DlyCrcEn & |DlyCrcCnt) 
                              )) | (~MRxDV & StateData[1]);


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ByteCnt[15:0] <=  16'd0;
  else
    begin
      if(ResetByteCounter)
        ByteCnt[15:0] <=  16'd0;
      else
      if(IncrementByteCounter)
        ByteCnt[15:0] <=  ByteCnt[15:0] + 16'd1;
     end
end
assign ResetFrameByteCounter = (MRxDV & ((StatePreamble & ByteCnt == 'd13)| (StateSFD &ByteCnt == 1 )| StateData[1] & ByteCntMaxFrame)) | StateIdle;


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    frame_ByteCnt[15:0] <=  16'd0;
  else
    begin
      if(ResetFrameByteCounter)
        frame_ByteCnt[15:0] <=  16'd0;
      else
      if((StateDA  & Rx_NibCnt == 'd1 )| (StateSA & Rx_NibCnt == 'd1)| (StateLength & Rx_NibCnt == 'd1) | StateData[1])
        frame_ByteCnt[15:0] <=  frame_ByteCnt[15:0] + 16'd1;
     end
end

assign ByteCntDelayed = ByteCnt + 16'd4;
assign ByteCntOut = DlyCrcEn ? ByteCntDelayed : ByteCnt;

assign ByteCntEq0       = ByteCnt == 16'd0;
assign ByteCntEq1       = ByteCnt == 16'd1;
assign ByteCntEq2       = ByteCnt == 16'd2; 
assign ByteCntEq3       = ByteCnt == 16'd3; 
assign ByteCntEq4       = ByteCnt == 16'd4; 
assign ByteCntEq5       = ByteCnt == 16'd5; 
assign ByteCntEq6       = ByteCnt == 16'd6;
assign ByteCntEq7       = ByteCnt == 16'd7;
assign ByteCntGreat2    = ByteCnt >  16'd2;
assign ByteCntSmall7    = ByteCnt <  16'd7;
assign ByteCntMax       = ByteCnt == 16'hffff;
assign ByteCntMaxFrame  = ByteCnt == 16'd2048 & ~HugEn;



assign ResetIFGCounter = (StateIdle | StatePreamble)  &  MRxDV & MRxDEq5 | StateDrop;


assign IncrementIFGCounter = ~ResetIFGCounter & (StateDrop | StateIdle | StatePreamble ) & ~IFGCounterEq24;

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    IFGCounter[4:0] <=  5'h0;
  else
    begin
      if(ResetIFGCounter)
        IFGCounter[4:0] <=  5'h0;
      else
      if(IncrementIFGCounter)
        IFGCounter[4:0] <=  IFGCounter[4:0] + 5'd1; 
    end
end



assign IFGCounterEq24 = (IFGCounter[4:0] == 5'd23) | r_IFG; // 24*400 = 9600 ns or r_IFG is set to 1


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    DlyCrcCnt[3:0] <=  4'h0;
  else
    begin
      if(DlyCrcCnt[3:0] == 4'h9)
        DlyCrcCnt[3:0] <=  4'h0;
      else
      if(DlyCrcEn & StateSFD)	
        DlyCrcCnt[3:0] <=  4'h1;
      else
      if(DlyCrcEn & (|DlyCrcCnt[3:0]))
        DlyCrcCnt[3:0] <=  DlyCrcCnt[3:0] + 4'd1;
    end
end


endmodule

