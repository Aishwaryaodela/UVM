//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:43:06 06/07/2020 
// Design Name: 
// Module Name:    eth_txstatem 
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
module eth_txstatem  (MTxClk, Resetn, ExcessiveDefer, CarrierSense, NibCnt, IPGT, IPGR1, 
                      IPGR2, FullD, TxStartFrm, TxEndFrm, TxUnderRun, Collision, UnderRun, 
                      StartTxDone, TooBig, NibCntEq7, NibCntEq15, MaxFrame, Pad, No_Preamble,CrcEn, 
                      NibbleMinFl, RandomEq0, ColWindow, RetryMax, NoBckof, RandomEqByteCnt,
                      StateIdle, StateIPG, StatePreamble, StateSFD, StateSA, StateDA, StateLength, StateData, StatePAD, StateFCS, 
                      StateJam, StateJam_q, StateBackOff, StateDefer, StartFCS, StartJam, 
                      StartBackoff, StartDefer, DeferIndication, StartPreamble, StartSFD,StartSA,StartDA,StartLength,StartData, StartIPG
                     );

input MTxClk;
input Resetn;
input ExcessiveDefer;
input CarrierSense;
input [6:0] NibCnt;
input [6:0] IPGT;
input [6:0] IPGR1;
input [6:0] IPGR2;
input FullD;
input TxStartFrm;
input TxEndFrm;
input TxUnderRun;
input Collision;
input UnderRun;
input StartTxDone; 
input TooBig;
input NibCntEq7;
input NibCntEq15;
input MaxFrame;
input Pad;
input No_Preamble;
input CrcEn;
input NibbleMinFl;
input RandomEq0;
input ColWindow;
input RetryMax;
input NoBckof;
input RandomEqByteCnt;


output StateIdle;         // Idle state
output StateIPG;          // IPG state
output StatePreamble;     // Preamble state
output StateSFD;		  // SFD State
output StateSA;			  // Source address state
output StateDA;			  // destination address state
output StateLength;		  // Payload length state
output [1:0] StateData;   // Data state
output StatePAD;          // PAD state
output StateFCS;          // FCS state
output StateJam;          // Jam state
output StateJam_q;        // Delayed Jam state
output StateBackOff;      // Backoff state
output StateDefer;        // Defer state

output StartFCS;          // FCS state will be activated in next clock
output StartJam;          // Jam state will be activated in next clock
output StartBackoff;      // Backoff state will be activated in next clock
output StartDefer;        // Defer state will be activated in next clock
output DeferIndication;
output StartPreamble;     // Preamble state will be activated in next clock
output reg StartSFD;	  // SFD state will be activated in next clock
output StartSA;			  // Source Address state will be activated in next clock added
output StartDA;			  // Destination Address state will be activated in next clock added
output StartLength;		  // Payload Length state will be activated in next clock added
output [1:0] StartData;   // Data state will be activated in next clock
output StartIPG;          // IPG state will be activated in next clock

localparam STATE_DEFER = 0,STATE_IPG = 1,STATE_IDLE = 2,STATE_PREAMBLE = 3,STATE_SFD = 4,STATE_DA = 5,STATE_SA = 6,
		STATE_LENGTH = 7,STATE_DATA0 = 8,STATE_DATA1 = 9,STATE_PAD = 10,STATE_FCS = 11,STATE_JAM = 12,STATE_BACKOFF =13;

reg [3:0] state_tx;


wire StateIdle 			= (state_tx == STATE_IDLE);
wire StateIPG 			= (state_tx == STATE_IPG);
wire StatePreamble 		= (state_tx == STATE_PREAMBLE);
wire StateSFD 			= (state_tx == STATE_SFD);
wire StateSA			= (state_tx == STATE_SA);
wire StateDA			= (state_tx == STATE_DA);
wire StateLength		= (state_tx == STATE_LENGTH);
wire [1:0] StateData 	= {(state_tx == STATE_DATA1),(state_tx == STATE_DATA0)};
wire StatePAD 			= (state_tx == STATE_PAD);
wire StateFCS 			= (state_tx == STATE_FCS);
wire StateJam 			= (state_tx == STATE_JAM);
wire StateBackOff 		= (state_tx == STATE_BACKOFF);
wire StateDefer 		= (state_tx == STATE_DEFER);

reg Rule1;
reg StateJam_q;

wire NibCntEq13 = (NibCnt == 'd13);
// Defining the next state
assign StartIPG = (state_tx == STATE_DEFER) & ~ExcessiveDefer & ~CarrierSense;

assign StartIdle = (state_tx == STATE_IPG) & (Rule1 & NibCnt[6:0] >= IPGT | ~Rule1 & NibCnt[6:0] >= IPGR2);

assign StartPreamble = (FullD == 1'b0)? ((state_tx == STATE_IDLE)& TxStartFrm & ~CarrierSense & ~No_Preamble) : ((state_tx == STATE_IDLE)& TxStartFrm & ~No_Preamble);

//Updated by Moschip Team
//Note: 1. Adding below four extra signals inorder to support the Tx_path of Ethernet. 
//		2. Which helps to send the complete ethernet packet 
//		3. Signals are StartSFD,StartSA,StartDA,Startlength.
//		4. Considering preamble,SFD,SA,DA,length are the control information. So cheking for the carriersense.

always @(*)
begin
	if(~No_Preamble)
	begin
			StartSFD = (state_tx == STATE_PREAMBLE) & NibCntEq13;
	end
	else
	begin
		if(FullD == 1'b0)
			StartSFD = ((state_tx == STATE_IDLE) & TxStartFrm & ~CarrierSense);
		else
			StartSFD = ((state_tx == STATE_IDLE) & TxStartFrm);
	end
end

assign StartDA = ((state_tx == STATE_SFD) & NibCnt == 'd1);

assign StartSA = ((state_tx == STATE_DA) & NibCnt == 'd11);

assign StartLength = ((state_tx == STATE_SA) & (NibCnt == 'd11));

assign StartData[0] = ~Collision & ((state_tx == STATE_LENGTH) & (NibCnt == 'd3)| (state_tx == STATE_DATA1) & ~TxEndFrm);

assign StartData[1] = ~Collision & (state_tx == STATE_DATA0) & ~TxUnderRun & ~MaxFrame;

assign StartPAD = ~Collision & (state_tx == STATE_DATA1)& TxEndFrm & Pad & ~NibbleMinFl;

assign StartFCS = ~Collision & (state_tx == STATE_DATA1) & TxEndFrm & (~Pad | Pad & NibbleMinFl) & CrcEn
                | ~Collision & (state_tx == STATE_PAD) & NibbleMinFl & CrcEn;

assign StartJam = (Collision | UnderRun) & (((state_tx == STATE_PREAMBLE) & NibCntEq13)|((state_tx == STATE_SFD)& (NibCnt == 'd1)) 
|((state_tx == STATE_SA) & (NibCnt == 'd11))| (((state_tx == STATE_DA) & (NibCnt == 'd11)))|(((state_tx == STATE_LENGTH) & (NibCnt == 'd3)))|((state_tx == STATE_DATA0)|(state_tx == STATE_DATA1)) | StatePAD | StateFCS);

assign StartBackoff = (state_tx == STATE_JAM) & ~RandomEq0 & ColWindow & ~RetryMax & NibCntEq7 & ~NoBckof;

assign StartDefer = (state_tx == STATE_IPG) & ~Rule1 & CarrierSense & NibCnt[6:0] <= IPGR1 & NibCnt[6:0] != IPGR2
                  | (state_tx == STATE_IDLE) & CarrierSense 
                  | (state_tx == STATE_JAM) & NibCntEq7 & (NoBckof | RandomEq0 | ~ColWindow | RetryMax)
                  | (state_tx == STATE_BACKOFF) & (TxUnderRun | RandomEqByteCnt)
                  | StartTxDone | TooBig;
				  
assign DeferIndication = (state_tx == STATE_IDLE) & CarrierSense;

always @(posedge MTxClk or negedge Resetn)
begin
	if(Resetn == 0)
		StateJam_q <= 1'b0;
	else	
		StateJam_q <= StateJam;
end


	
always@(posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin	
		state_tx <= STATE_DEFER;
	end
  else
  begin
	case(state_tx)
	STATE_DEFER : begin	
						if(StartIPG)
							state_tx <= STATE_IPG;
				  end
	STATE_IPG : begin
					if(StartDefer)
							state_tx <= STATE_DEFER;
					else 
					begin
						if(StartIdle)
							state_tx <= STATE_IDLE;
					end
				  end
	STATE_IDLE	: begin
					if(StartDefer)
						state_tx <= STATE_DEFER;
					else
						if(StartPreamble)
							state_tx <= STATE_PREAMBLE;
						else
						begin
							if(StartSFD)
								state_tx <= STATE_SFD;
						end
				  end
	STATE_PREAMBLE : begin
						if(StartJam)
							state_tx <= STATE_JAM;	
						else
							if(StartSFD)
								state_tx <= STATE_SFD;
					 end
	STATE_SFD : begin
				if(StartJam)
					state_tx <= STATE_JAM;
				else
					if(StartDA)
						state_tx <= STATE_DA;
				end
	STATE_DA : begin
				if(StartJam)
					state_tx <= STATE_JAM;
				else
					if(StartSA)
						state_tx <= STATE_SA;
			   end
	STATE_SA: begin
				if(StartJam)
					state_tx <= STATE_JAM;
				else
					if(StartLength)
						state_tx <= STATE_LENGTH;
			  end
	STATE_LENGTH: begin
					if(StartJam)
						state_tx <= STATE_JAM;
					else
						if(StartData[0])
							state_tx <= STATE_DATA0;
				  end
	STATE_DATA0	:begin
					if(StartDefer)
						state_tx <= STATE_DEFER;
					else
					begin
						if(StartJam)	
								state_tx <= STATE_JAM;
						else
						begin
							if(StartData[1])
								state_tx <= STATE_DATA1;
						end
					end
				 end
	STATE_DATA1 : begin
					if(StartDefer)
						state_tx <= STATE_DEFER;
					else 
					begin
						if(StartJam)
							state_tx <= STATE_JAM;
						else
						begin 
							if(StartData[0])
								state_tx <= STATE_DATA0;
							else
							begin
								if(StartPAD)
									state_tx <= STATE_PAD;
								else
								begin
									if(StartFCS)
										state_tx <= STATE_FCS;
								end
							end
						end
					end
				 end
	STATE_PAD:begin
				if(StartJam)
					state_tx <= STATE_JAM;
				else
				begin
					if(StartFCS)
						state_tx <= STATE_FCS;
				end
			  end
	STATE_FCS: begin
				if(StartDefer)
					state_tx <= STATE_DEFER;
				else
				begin
					if(StartJam)
						state_tx <= STATE_JAM;
				end
			   end
	STATE_JAM:begin
				if(StartDefer)
					state_tx <= STATE_DEFER;
				else
				begin
					if(StartBackoff)
						state_tx <= STATE_BACKOFF;
				end
			  end
	STATE_BACKOFF:begin
					if(StartDefer)
						state_tx <= STATE_DEFER;
				  end
	endcase
   end	
 end
			
// This sections defines which interpack gap rule to use
always @ (posedge MTxClk or negedge Resetn)
begin
  if(Resetn == 0)
    Rule1 <=  1'b0;
  else
    begin
      if(StateIdle | StateBackOff)
        Rule1 <=  1'b0;
      else
      if((StatePreamble & ~No_Preamble)|(StateSFD & No_Preamble)| FullD)	
        Rule1 <=  1'b1;
    end
end
			
endmodule

