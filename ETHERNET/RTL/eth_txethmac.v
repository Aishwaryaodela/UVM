//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:42:46 06/07/2020 
// Design Name: 
// Module Name:    eth_txethmac 
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
module eth_txethmac (MTxClk, Resetn, TxStartFrm, TxEndFrm, TxUnderRun, TxData, CarrierSense, r_LoopBck,
                     Collision, Pad,No_Preamble,MAC_Address,DA_Address,Payload_length, CrcEn, FullD, HugEn, DlyCrcEn, MinFL, MaxFL, IPGT, 
                     IPGR1, IPGR2, CollValid, MaxRet, NoBckof, ExDfrEn, 
                     MTxD, MTxEn, MTxErr, TxDone, TxRetry, TxAbort, TxUsedData, WillTransmit, 
                     ResetCollision, RetryCnt, StartTxDone, StartTxAbort, MaxCollisionOccured,
                     LateCollision, DeferIndication, StatePreamble,StateSFD,StateDA,StateSA,StateLength, StateData
                    );


input MTxClk;                   // Transmit clock (from PHY)
input Resetn;                    // Resetn
input TxStartFrm;               // Transmit packet start frame
input TxEndFrm;                 // Transmit packet end frame
input TxUnderRun;               // Transmit packet under-run
input [7:0] TxData;             // Transmit packet data byte
input CarrierSense;             // Carrier sense (synchronized)
input Collision;                // Collision (synchronized)
input Pad;                      // Pad enable (from register)
input No_Preamble;				//No_Preamble (from register)	added
input [47:0] MAC_Address;		//MAC_Address(Source address)	added
input [47:0] DA_Address;		// PHY_address(destination address) added
input [15:0] Payload_length;	// Length (from Buffer descriptors)
input CrcEn;                    // Crc enable (from register)
input FullD;                    // Full duplex (from register)
input HugEn;                    // Huge packets enable (from register)
input DlyCrcEn;                 // Delayed Crc enabled (from register)
input r_LoopBck;				//Loopback (From Register)
input [15:0] MinFL;             // Minimum frame length (from register)
input [15:0] MaxFL;             // Maximum frame length (from register)
input [6:0] IPGT;               // Back to back transmit inter packet gap parameter (from register)
input [6:0] IPGR1;              // Non back to back transmit inter packet gap parameter IPGR1 (from register)
input [6:0] IPGR2;              // Non back to back transmit inter packet gap parameter IPGR2 (from register)
input [5:0] CollValid;          // Valid collision window (from register)
input [3:0] MaxRet;             // Maximum retry number (from register)
input NoBckof;                  // No backoff (from register)
input ExDfrEn;                  // Excessive defferal enable (from register)

output [3:0] MTxD;              // Transmit nibble (to PHY)
output MTxEn;                   // Transmit enable (to PHY)
output MTxErr;                  // Transmit error (to PHY)
output TxDone;                  // Transmit packet done (to RISC)
output TxRetry;                 // Transmit packet retry (to RISC)
output TxAbort;                 // Transmit packet abort (to RISC)
output TxUsedData;              // Transmit packet used data (to RISC)
output WillTransmit;            // Will transmit (to RxEthMAC)
output ResetCollision;          // Resetn Collision (for synchronizing collision)
output [3:0] RetryCnt;          // Latched Retry Counter for tx status purposes
output StartTxDone;
output StartTxAbort;
output MaxCollisionOccured;
output LateCollision;
output DeferIndication;
output StatePreamble;
output StateSFD;
output StateDA;
output StateSA;
output StateLength;
output [1:0] StateData;

reg [3:0] MTxD;
reg MTxEn;
reg MTxErr;
reg TxDone;
reg TxRetry;
reg TxAbort;
reg TxUsedData;
reg WillTransmit;
reg ColWindow;
reg StopExcessiveDeferOccured;
reg [3:0] RetryCnt;
reg [3:0] MTxD_d;
reg StatusLatch;
reg PacketFinished_q;
reg PacketFinished;


wire ExcessiveDeferOccured;
wire StartIPG;
wire StartPreamble;
wire StartSFD;	
wire StartSA;	//added
wire StartDA;
wire StartLength;

wire [1:0] StartData;
wire StartFCS;
wire StartJam;
wire StartDefer;
wire StartBackoff;
wire StateDefer;
wire StateIPG;
wire StateIdle;
//wire StateSA;
//wire StateDA;
//wire StateLength;
wire StatePAD;
wire StateFCS;
wire StateJam;
wire StateJam_q;
wire StateBackOff;
//wire StateSFD;
wire StartTxRetry;
wire UnderRun;
wire TooBig;
wire [31:0] Crc;
wire CrcError;
wire [2:0] DlyCrcCnt;
wire [15:0] NibCnt;
wire NibCntEq7;
wire NibCntEq15;
wire NibbleMinFl;
wire ExcessiveDefer;
wire [15:0] ByteCnt;
wire MaxFrame;
wire RetryMax;
wire RandomEq0;
wire RandomEqByteCnt;
wire PacketFinished_d;



assign ResetCollision = ~(StatePreamble | StateSFD | StateSA | StateDA | StateLength |(|StateData) | StatePAD | StateFCS);

assign ExcessiveDeferOccured = TxStartFrm & StateDefer & ExcessiveDefer & ~StopExcessiveDeferOccured;

assign StartTxDone = ~Collision & (StateFCS & NibCntEq7 | StateData[1] & TxEndFrm & (~Pad | Pad & NibbleMinFl) & ~CrcEn);

assign UnderRun = StateData[0] & TxUnderRun & ~Collision;

assign TooBig = ~Collision & MaxFrame & (StateData[0] & ~TxUnderRun | StateFCS);

assign StartTxRetry = StartJam & (ColWindow & ~RetryMax) & ~UnderRun;

assign LateCollision = StartJam & ~ColWindow & ~UnderRun;

assign MaxCollisionOccured = StartJam & ColWindow & RetryMax;

assign StartTxAbort = TooBig | UnderRun | ExcessiveDeferOccured | LateCollision | MaxCollisionOccured;		//Update for the Padding error


// StopExcessiveDeferOccured
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    StopExcessiveDeferOccured <=  1'b0;
  else
    begin
      if(~TxStartFrm)
        StopExcessiveDeferOccured <=  1'b0;
      else
      if(ExcessiveDeferOccured)
        StopExcessiveDeferOccured <=  1'b1;
    end
end


// Collision Window
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    ColWindow <=  1'b1;
  else
    begin  
      if(~Collision & ByteCnt[5:0] == CollValid[5:0] & (StateData[1] | StatePAD & NibCnt[0] | StateFCS & NibCnt[0]))
        ColWindow <=  1'b0;
      else
      if(StateIdle | StateIPG)
        ColWindow <=  1'b1;
    end
end


// Start Window
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    StatusLatch <=  1'b0;
  else
    begin
      if(~TxStartFrm)
        StatusLatch <=  1'b0;
      else
      if(ExcessiveDeferOccured | StateIdle)
        StatusLatch <=  1'b1;
     end
end


// Transmit packet used data
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxUsedData <=  1'b0;
  else
    TxUsedData <=  |StartData;
end


// Transmit packet done
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxDone <=  1'b0;
  else
    begin
      if(TxStartFrm & ~StatusLatch)
        TxDone <=  1'b0;
      else
      if(StartTxDone)
        TxDone <=  1'b1;
    end
end


// Transmit packet retry
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxRetry <=  1'b0;
  else
    begin
      if(TxStartFrm & ~StatusLatch)
        TxRetry <=  1'b0;
      else
      if(StartTxRetry)
        TxRetry <=  1'b1;
     end
end                                    


// Transmit packet abort
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    TxAbort <=  1'b0;
  else
    begin
      if(TxStartFrm & ~StatusLatch & ~ExcessiveDeferOccured)
        TxAbort <=  1'b0;
      else
      if(StartTxAbort)
        TxAbort <=  1'b1;
    end
end


// Retry counter
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    RetryCnt[3:0] <=  4'h0;
  else
    begin
      if(ExcessiveDeferOccured | UnderRun | TooBig | StartTxDone | TxUnderRun 
          | StateJam & NibCntEq7 & (~ColWindow | RetryMax))
        RetryCnt[3:0] <=  4'h0;
      else
      if(StateJam & NibCntEq7 & ColWindow & (RandomEq0 | NoBckof) | StateBackOff & RandomEqByteCnt)
        RetryCnt[3:0] <=  RetryCnt[3:0] + 1;
    end
end


assign RetryMax = RetryCnt[3:0] == MaxRet[3:0];

reg [47:0] Source_Address;	// = MAC_Address;
reg [47:0] Destination_address; 
reg [15:0] Data_payload_length;
always @(posedge MTxClk or negedge Resetn)
begin
	if(Resetn == 0)
	begin
		Source_Address <= 0;
		Destination_address <= 0;
	end
	else 
	begin
		case(1)
		StateDA: begin
					if(NibCnt < 11)
						Destination_address <= Destination_address << 4;
				 end
		StateSA: begin
					if(NibCnt < 11)
						Source_Address <= Source_Address << 4;
				 end
		StateLength : begin
						if(NibCnt < 3)
							Data_payload_length <= Data_payload_length >> 4;
					  end
		StateSFD: begin 
					Source_Address <= MAC_Address;
					Destination_address <= DA_Address;
					Data_payload_length <= Payload_length;
				  end
		endcase
	end
end
reg [47:0] DA_Address1;
always@(*)
begin
	if(r_LoopBck)
		DA_Address1 = MAC_Address;
	else
		DA_Address1 = DA_Address;
end

// Transmit nibble
always @ (StatePreamble or StateData or StateFCS or StateJam or StateSFD or StateDA or StateSA or StateLength or TxData or 
          Crc or NibCntEq15 or NibCnt or Destination_address or Source_Address or Data_payload_length)
begin
  if(StateData[0])
    MTxD_d[3:0] = TxData[3:0];                                  // Lower nibble
  else begin
		if(StateData[1])
			MTxD_d[3:0] = TxData[7:4];                                  // Higher nibble
		else begin
			if(StateFCS)
				MTxD_d[3:0] = {~Crc[28], ~Crc[29], ~Crc[30], ~Crc[31]};     // Crc
			else begin
				if(StateJam)
					MTxD_d[3:0] = 4'h9;                                         // Jam pattern
				else begin
					if(StatePreamble)
					begin
						MTxD_d[3:0] = 4'h5; 		//Preamble
					end
					else begin
						if(StateSFD) 
						 begin
							if(NibCnt == 'd1)
								MTxD_d[3:0] = 4'hd;                                       // SFD
							else
								MTxD_d[3:0] = 4'h5;    
						 end
						else begin
							 if(StateDA)
							    begin	
									case(NibCnt)
										'd0:MTxD_d[3:0] = DA_Address1[47:44];
										'd1:MTxD_d[3:0] = DA_Address1[43:40];
										'd2:MTxD_d[3:0] = DA_Address1[39:36];
										'd3:MTxD_d[3:0] = DA_Address1[35:32];
										'd4:MTxD_d[3:0] = DA_Address1[31:28];
										'd5:MTxD_d[3:0] = DA_Address1[27:24];
										'd6:MTxD_d[3:0] = DA_Address1[23:20];
										'd7:MTxD_d[3:0] = DA_Address1[19:16];
										'd8:MTxD_d[3:0] = DA_Address1[15:12];
										'd9:MTxD_d[3:0] = DA_Address1[11:8];
										'd10:MTxD_d[3:0] = DA_Address1[7:4];
										'd11:MTxD_d[3:0] = DA_Address1[3:0];
									endcase	
								end
							 else begin
									if(StateSA)
									begin
										case(NibCnt)
										'd0:MTxD_d[3:0] = MAC_Address[47:44];
										'd1:MTxD_d[3:0] = MAC_Address[43:40];
										'd2:MTxD_d[3:0] = MAC_Address[39:36];
										'd3:MTxD_d[3:0] = MAC_Address[35:32];
										'd4:MTxD_d[3:0] = MAC_Address[31:28];
										'd5:MTxD_d[3:0] = MAC_Address[27:24];
										'd6:MTxD_d[3:0] = MAC_Address[23:20];
										'd7:MTxD_d[3:0] = MAC_Address[19:16];
										'd8:MTxD_d[3:0] = MAC_Address[15:12];
										'd9:MTxD_d[3:0] = MAC_Address[11:8];
										'd10:MTxD_d[3:0] = MAC_Address[7:4];
										'd11:MTxD_d[3:0] = MAC_Address[3:0];
										endcase	
									end
									else begin
										if(StateLength)		//0040
										begin
											case(NibCnt)
											'd0:MTxD_d[3:0] = Payload_length[11:8];
											'd1:MTxD_d[3:0] = Payload_length[15:12];
											'd2:MTxD_d[3:0] = Payload_length[3:0];
											'd3:MTxD_d[3:0] = Payload_length[7:4];
											endcase
										end
										else
											MTxD_d[3:0] = 4'h0;
									end
							 end
						end
					end
				end
			end
		end
	end
end


// Transmit Enable
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    MTxEn <=  1'b0;
  else
    MTxEn <=  StatePreamble| StateSFD | StateSA | StateDA | StateLength |(|StateData) | StatePAD | StateFCS | StateJam;	
end


// Transmit nibble
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    MTxD[3:0] <=  4'h0;
  else
    MTxD[3:0] <=  MTxD_d[3:0];
end


// Transmit error
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    MTxErr <=  1'b0;
  else
    MTxErr <=  TooBig | UnderRun;		
end


// WillTransmit
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    WillTransmit <=   1'b0;
  else
    WillTransmit <=  StartPreamble | StatePreamble | StateSFD | StateSA | StateDA | StateLength |(|StateData) | StatePAD | StateFCS | StateJam;
end


assign PacketFinished_d = StartTxDone | TooBig | UnderRun | LateCollision | MaxCollisionOccured | ExcessiveDeferOccured;


// Packet finished
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      PacketFinished <=  1'b0;
      PacketFinished_q  <=  1'b0;
    end
  else
    begin
      PacketFinished <=  PacketFinished_d;
      PacketFinished_q  <=  PacketFinished;
    end
end


// Connecting module Counters
eth_txcounters txcounters1 (.StatePreamble(StatePreamble), .StateIPG(StateIPG), .StateSA(StateSA),.StateDA(StateDA),.StateLength(StateLength),
							.StateData(StateData),.StatePAD(StatePAD), .StateFCS(StateFCS), .StateJam(StateJam), .StateBackOff(StateBackOff), 
                            .StateDefer(StateDefer), .StateIdle(StateIdle), .StartDefer(StartDefer), .StartIPG(StartIPG), 
                            .StartFCS(StartFCS), .StartJam(StartJam), .TxStartFrm(TxStartFrm), .MTxClk(MTxClk), 
                            .Resetn(Resetn), .MinFL(MinFL), .MaxFL(MaxFL), .HugEn(HugEn), .ExDfrEn(ExDfrEn), 
                            .PacketFinished_q(PacketFinished_q), .DlyCrcEn(DlyCrcEn), .StartBackoff(StartBackoff), 
                            .StateSFD(StateSFD), .ByteCnt(ByteCnt), .NibCnt(NibCnt), .ExcessiveDefer(ExcessiveDefer), 
                            .NibCntEq7(NibCntEq7), .NibCntEq15(NibCntEq15), .MaxFrame(MaxFrame), .NibbleMinFl(NibbleMinFl), 
                            .DlyCrcCnt(DlyCrcCnt)
                           );


// Connecting module StateM
eth_txstatem txstatem1 (.MTxClk(MTxClk), .Resetn(Resetn), .ExcessiveDefer(ExcessiveDefer), .CarrierSense(CarrierSense), 
                        .NibCnt(NibCnt[6:0]), .IPGT(IPGT), .IPGR1(IPGR1), .IPGR2(IPGR2), .FullD(FullD), 
                        .TxStartFrm(TxStartFrm), .TxEndFrm(TxEndFrm), .TxUnderRun(TxUnderRun), .Collision(Collision), 
                        .UnderRun(UnderRun), .StartTxDone(StartTxDone), .TooBig(TooBig), .NibCntEq7(NibCntEq7), 
                        .NibCntEq15(NibCntEq15), .MaxFrame(MaxFrame), .Pad(Pad), .No_Preamble(No_Preamble),.CrcEn(CrcEn), 
                        .NibbleMinFl(NibbleMinFl), .RandomEq0(RandomEq0), .ColWindow(ColWindow), .RetryMax(RetryMax), 
                        .NoBckof(NoBckof), .RandomEqByteCnt(RandomEqByteCnt), .StateIdle(StateIdle), 
                        .StateIPG(StateIPG), .StatePreamble(StatePreamble), .StateSFD(StateSFD),.StateSA(StateSA),.StateDA(StateDA),
						.StateLength(StateLength),.StateData(StateData), .StatePAD(StatePAD), 
                        .StateFCS(StateFCS), .StateJam(StateJam), .StateJam_q(StateJam_q), .StateBackOff(StateBackOff), 
                        .StateDefer(StateDefer), .StartFCS(StartFCS), .StartJam(StartJam), .StartBackoff(StartBackoff), 
                        .StartDefer(StartDefer), .DeferIndication(DeferIndication), .StartPreamble(StartPreamble), .StartSFD(StartSFD),
						.StartLength(StartLength),.StartData(StartData), .StartIPG(StartIPG),.StartSA(StartSA),.StartDA(StartDA)
                       );


wire Enable_Crc;
reg [3:0] Data_Crc;
wire Initialize_Crc;

assign Enable_Crc = ~StateFCS;

always@(*)
begin
	case(1)
	StateDA : begin
				Data_Crc[0] = MTxD_d[3];
				Data_Crc[1] = MTxD_d[2];
				Data_Crc[2] = MTxD_d[1];
				Data_Crc[3] = MTxD_d[0];
			  end
	StateSA : begin
				Data_Crc[0] = MTxD_d[3];
				Data_Crc[1] = MTxD_d[2];
				Data_Crc[2] = MTxD_d[1];
				Data_Crc[3] = MTxD_d[0];
			  end
	StateLength : begin
					Data_Crc[0] = MTxD_d[3];
					Data_Crc[1] = MTxD_d[2];
					Data_Crc[2] = MTxD_d[1];
					Data_Crc[3] = MTxD_d[0];
				  end
	StateData[0] : begin
					Data_Crc[0] = TxData[3];
					Data_Crc[1] = TxData[2];
					Data_Crc[2] = TxData[1];
					Data_Crc[3] = TxData[0];
				   end
	StateData[1] : begin
					Data_Crc[0] = TxData[7];
					Data_Crc[1] = TxData[6];
					Data_Crc[2] = TxData[5];
					Data_Crc[3] = TxData[4];
				   end
	default: begin
				Data_Crc[0] = 1'b0;
				Data_Crc[1] = 1'b0;
				Data_Crc[2] = 1'b0;
				Data_Crc[3] = 1'b0;
			 end
	
	endcase
end

assign Initialize_Crc = StateIdle | StatePreamble | StateSFD | (|DlyCrcCnt);	


// Connecting module Crc
eth_crc txcrc (.Clk(MTxClk), .Resetn(Resetn), .Data(Data_Crc), .Enable(Enable_Crc), .Initialize(Initialize_Crc), 
               .Crc(Crc), .CrcError(CrcError)
              );


// Connecting module Random
eth_random random1 (.MTxClk(MTxClk), .Resetn(Resetn), .StateJam(StateJam), .StateJam_q(StateJam_q), .RetryCnt(RetryCnt), 
                    .NibCnt(NibCnt), .ByteCnt(ByteCnt[9:0]), .RandomEq0(RandomEq0), .RandomEqByteCnt(RandomEqByteCnt));




endmodule

