//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:40:08 06/07/2020 
// Design Name: 
// Module Name:    eth_rxethmac 
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
module eth_rxethmac (MRxClk, MRxDV, MRxD,MRxErr, Resetn, Transmitting, MaxFL,r_MinFL, r_IFG,No_Preamble,
                     HugEn,Pad, DlyCrcEn, RxData, RxValid, RxStartFrm, RxEndFrm,
                     ByteCnt, ByteCntEq0, ByteCntGreat2, ByteCntMaxFrame,
                     CrcError, StateIdle, StatePreamble, StateSFD, StateData, StateDA, StateSA, StateLength,
                     MAC, r_Pro, r_Bro,r_Iam,r_HASH0, r_HASH1, RxAbort, AddressMiss,MRxErr_Detected,Length_Vs_Payload_error,Length_vs_payload_mismatch,
                     PassAll, ControlFrmAddressOK
                    );

input         MRxClk;
input         MRxDV;
input   [3:0] MRxD;
input 		  MRxErr;
input         Transmitting;
input         HugEn;
input 		  Pad;
input         DlyCrcEn;
input  [15:0] r_MinFL;
input  [15:0] MaxFL;
input         r_IFG;
input 		  No_Preamble;
input         Resetn;
input  [47:0] MAC;     //  Station Address  
input         r_Bro;   //  broadcast disable
input         r_Pro;   //  promiscuous enable 
input 		  r_Iam;   //  Individual Address mode
input [31:0]  r_HASH0; //  lower 4 bytes Hash Table
input [31:0]  r_HASH1; //  upper 4 bytes Hash Table
input         PassAll;
input         ControlFrmAddressOK;

output  [7:0] RxData;
output        RxValid;
output        RxStartFrm;
output        RxEndFrm;
output [15:0] ByteCnt;
output        ByteCntEq0;
output        ByteCntGreat2;
output        ByteCntMaxFrame;
output        CrcError;
output        StateIdle;
output        StatePreamble;
output        StateSFD;
output  [1:0] StateData;
output 		  StateDA;
output 		  StateSA;
output 		  StateLength;
output        RxAbort;
output        AddressMiss;
output 		  MRxErr_Detected;
output 		  Length_Vs_Payload_error;
output 		  Length_vs_payload_mismatch;



reg 		  Length_Vs_Payload_error;
wire 		  Length_vs_payload_mismatch;
reg 	[15:0]Frame_Length;
reg     [7:0] RxData;
reg           RxValid;
reg           RxStartFrm;
reg           RxEndFrm;
reg     [5:0] CrcHash;
reg           CrcHashGood;
reg 		  CrcHashGood_next;
reg           DelayData;
reg     [7:0] LatchedByte;
reg     [7:0] RxData_d;
reg           RxValid_d1;
reg 		  RxValid_d2;
reg 		  RxValid_d3;
reg           RxStartFrm_d;
reg           RxEndFrm_d1;
reg 		  RxEndFrm_d2;
reg 		  Frame_drop;
reg 		  shift8_py_gt_len_pad1_dat0_f0;
reg 		  shift8_py_gt_len_pad1_dat0_f1;
reg 		  shift8_py_gt_len_pad1_dat0_f2;
reg 		  shift8_py_gt_len_pad1_dat0_f3;
reg 		  shift8_py_gt_len_pad1_dat0_f4;
reg 		  shift8_py_gt_len_pad1_dat0_f5;
reg 		  shift8_py_gt_len_pad1_dat0_f6;
reg 		  shift8_py_gt_len_pad1_dat0_f7;
reg 		  py_gt_len_pad1_dat0;
reg 		  payld_gt_maxfl_error;





wire          MRxDEqD;
wire          MRxDEq5;
wire          StateDrop;
wire          ByteCntEq1;
wire          ByteCntEq2;
wire          ByteCntEq3;
wire          ByteCntEq4;
wire          ByteCntEq5;
wire          ByteCntEq6;
wire          ByteCntEq7;
wire          ByteCntSmall7;
wire  [15:0]  frame_ByteCnt;
wire   [31:0] Crc;
wire          Enable_Crc;
wire          Initialize_Crc;
wire    [3:0] Data_Crc;
wire          GenerateRxValid;
wire          GenerateRxStartFrm;
wire          GenerateRxEndFrm;
wire          DribbleRxEndFrm;
wire    [3:0] DlyCrcCnt;
wire          IFGCounterEq24;
wire 		  Rx_NibCnt;
wire 		  Address_mismatch;
reg 		  Preamble_mismatch;
reg 		  SFD_mismatch;
wire       rxabort_statedrop;
reg endframe_d;
reg endframe_d1;
reg 		MRxErr_Detected;

assign MRxDEqD = MRxD == 4'hd;
assign MRxDEq5 = MRxD == 4'h5;


// Rx State Machine module
eth_rxstatem rxstatem1
  (.MRxClk(MRxClk),
   .Resetn(Resetn),
   .MRxDV(MRxDV),
   .No_Preamble(No_Preamble),
   .Rx_NibCnt(Rx_NibCnt),
   .Frame_drop(Frame_drop),
   .ByteCnt(ByteCnt),
   .ByteCntEq0(ByteCntEq0),
   .ByteCntGreat2(ByteCntGreat2),
   .Transmitting(Transmitting),
   .MRxDEq5(MRxDEq5),
   .MRxDEqD(MRxDEqD),
   .IFGCounterEq24(IFGCounterEq24),
   .ByteCntMaxFrame(ByteCntMaxFrame),
   .StateData(StateData),
   .StateIdle(StateIdle),
   .StatePreamble(StatePreamble),
   .StateSFD(StateSFD),
   .StateDA(StateDA),
   .StateSA(StateSA),
   .StateLength(StateLength),
   .StateDrop(StateDrop),
	.rxabort_statedrop(rxabort_statedrop)
   );


// Rx Counters module
eth_rxcounters rxcounters1
  (.MRxClk(MRxClk),
   .Resetn(Resetn),
   .MRxDV(MRxDV),
   .StateIdle(StateIdle),
   .StateSFD(StateSFD),
   .StateData(StateData),
   .StateDrop(StateDrop),
   .StatePreamble(StatePreamble),
   .StateDA(StateDA),
   .StateSA(StateSA),
   .StateLength(StateLength),
   .MRxDEq5(MRxDEq5),
   .MRxDEqD(MRxDEqD),
   .DlyCrcEn(DlyCrcEn),
   .DlyCrcCnt(DlyCrcCnt),
   .Transmitting(Transmitting),
   .MaxFL(MaxFL),
   .r_IFG(r_IFG),
   .HugEn(HugEn),
   .IFGCounterEq24(IFGCounterEq24),
   .ByteCntEq0(ByteCntEq0),
   .ByteCntEq1(ByteCntEq1),
   .ByteCntEq2(ByteCntEq2),
   .ByteCntEq3(ByteCntEq3),
   .ByteCntEq4(ByteCntEq4),
   .ByteCntEq5(ByteCntEq5),
   .ByteCntEq6(ByteCntEq6),
   .ByteCntEq7(ByteCntEq7),
   .ByteCntGreat2(ByteCntGreat2),
   .ByteCntSmall7(ByteCntSmall7),
   .ByteCntMaxFrame(ByteCntMaxFrame),
   .ByteCntOut(ByteCnt),
   .frame_ByteCnt(frame_ByteCnt),
   .Rx_NibCnt(Rx_NibCnt)
   );

// Rx Address Check

eth_rxaddrcheck rxaddrcheck1
  (.MRxClk(MRxClk),
   .Resetn( Resetn),
   .MRxD(MRxD),
   .LatchedByte(LatchedByte),
   .Rx_NibCnt(Rx_NibCnt),   
   .r_Bro (r_Bro),
   .r_Pro(r_Pro),
   .r_Iam(r_Iam),
   .ByteCntEq6(ByteCntEq6),
   .ByteCntEq7(ByteCntEq7),
   .ByteCntEq1(ByteCntEq1),
   .ByteCntEq2(ByteCntEq2),
   .ByteCntEq3(ByteCntEq3),
   .ByteCntEq4(ByteCntEq4),
   .ByteCntEq5(ByteCntEq5),
   .HASH0(r_HASH0),
   .HASH1(r_HASH1),
   .ByteCntEq0(ByteCntEq0),
   .CrcHash(CrcHash),
   .CrcHashGood(CrcHashGood),		
   .StateDA(StateDA),
   .StateSFD(StateSFD),
   .StateIdle(StateIdle),
   .StateDrop(StateDrop),
   .MAC(MAC),
   .Address_mismatch(Address_mismatch),
   .RxEndFrm(RxEndFrm),
   .AddressMiss(AddressMiss),
   .RxAddressInvalid(RxAddressInvalid),
   .PassAll(PassAll),
   .ControlFrmAddressOK(ControlFrmAddressOK)
   );
   
//Note: 1.Depending on any error of Frame below frame_error should be Generated.
//      2.And this signal should be high until end of the Frame.
//	    3.So that other logics(ex:fifo) should drop that Frame.    
//assign RxAbort = (endframe_d && AddressMiss) | rxabort_statedrop | Length_Vs_Payload_error;
assign RxAbort = (endframe_d1 && AddressMiss) | rxabort_statedrop | Length_Vs_Payload_error | (endframe_d1 && MRxErr_Detected);

assign Length_vs_payload_mismatch = (!shift8_py_gt_len_pad1_dat0_f5 && endframe_d);

assign Enable_Crc = (MRxDV & (StateDA | StateSA | StateLength |(|StateData & ~ByteCntMaxFrame))) |(~MRxDV & (|StateData & ~ByteCntMaxFrame)) ;		
assign Initialize_Crc = StateSFD | DlyCrcEn & (|DlyCrcCnt[3:0]) &
                        DlyCrcCnt[3:0] < 4'h9;


assign Data_Crc[0] = LatchedByte[7];	
assign Data_Crc[1] = LatchedByte[6];
assign Data_Crc[2] = LatchedByte[5];
assign Data_Crc[3] = LatchedByte[4];

// Connecting module Crc
eth_crc crcrx
  (.Clk(MRxClk),
   .Resetn(Resetn),
   .Data(Data_Crc),
   .Enable(Enable_Crc),
   .Initialize(Initialize_Crc), 
   .Crc(Crc),
   .CrcError(CrcError)
   );


// Latching CRC for use in the hash table
always @ (posedge MRxClk)
begin
  CrcHashGood <= CrcHashGood_next;  
end
always@(*)
begin
    CrcHashGood_next=(StateDA & Rx_NibCnt == 'd1) & ByteCntEq5; 
end
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0 | StateIdle)
    CrcHash[5:0] <=  6'h0;
  else
     if(CrcHashGood_next)
          CrcHash[5:0] <=  Crc[31:26];
end

// Output byte stream
always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      RxData_d[7:0]      <=  8'h0;
      DelayData          <=  1'b0;
      LatchedByte[7:0]   <=  8'h0;
      RxData[7:0]        <=  8'h0;
    end
  else
    begin 
      LatchedByte[7:0]   <=  {MRxD[3:0], LatchedByte[7:4]};
	  DelayData          <=  (StateDA & Rx_NibCnt == 'd1)|(StateSA & Rx_NibCnt == 'd1) | (StateLength & Rx_NibCnt == 'd1)|StateData[1];

      if(GenerateRxValid)
		//Data goes through DA,SA,Length and data States 
        RxData_d[7:0] <=  LatchedByte[7:0] & ({8{|StateData}} | {8{StateDA}} | {8{StateSA}} | {8{StateLength}});
      else
      if(~DelayData)
        // Delaying data to be valid for two cycles.
        // Zero when not active.
        RxData_d[7:0] <=  8'h0;

      RxData[7:0] <=  RxData_d[7:0];          // Output data byte
    end
end
//added code by Moschip Team on September 4th 2020

always @(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
	begin
		MRxErr_Detected <= 0;
	end
	else if(RxEndFrm)
	begin
		MRxErr_Detected <= 0;
	end
	else 
	begin
		case(1)
			StateDA,StateSA,StateLength,StateData[0],StateData[1]:begin
																	if(MRxErr)
																		MRxErr_Detected <= 1;
																	else
																		MRxErr_Detected <= MRxErr_Detected;
																  end
		endcase
	end
end

//added code by Moschip Team on June 15th

always @(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
	begin
		Frame_drop <= 0;
		Preamble_mismatch <= 0;
		SFD_mismatch <= 0;
	end
	else 
	begin 
		if(StateIdle)
		begin
			if(MRxDV)
			begin
				case(No_Preamble)
				0 : begin 
						if(MRxD != 'd5)
							begin
								Frame_drop <= 1;
								Preamble_mismatch <= 1;
							end
						else
							begin
								if(MRxErr == 1)
								begin
								Frame_drop <= 1;
								Preamble_mismatch <= 0;
								end
								else
								begin
								Frame_drop <= 0;
								Preamble_mismatch <= 0;
								end
							end
					end
				1: begin
						if(MRxD != 'd5)
						begin 
							Frame_drop <= 1;
							SFD_mismatch <= 1;
						end
						else
						begin
							if(MRxErr == 1)
							begin
							Frame_drop <= 1;
							SFD_mismatch <= 0;
							end
							else
							begin
							Frame_drop <= 0;
							SFD_mismatch <= 0;
							end
						end
				   end
				endcase
			end
			else
			begin
				Frame_drop <= 0;
				Preamble_mismatch <= 0;
				SFD_mismatch <= 0;
			end
		end
		else if(StatePreamble)
		begin
			if(LatchedByte[7:4] == 'd5)
			begin
				if(MRxErr)
				begin
				Frame_drop <= 1;
				Preamble_mismatch <= 0;
				end
				else
				begin
				Frame_drop <= 0;
				Preamble_mismatch <= 0;
				end
			end
			else
			begin
				Frame_drop <= 1;
				Preamble_mismatch <= 1;
			end
		end
		else 
			if(StateSFD)
			begin
				if((LatchedByte[7:4] == 'd5) & ByteCnt == 0)	
				begin
					if(MRxErr)
					begin
					Frame_drop <= 1;
					SFD_mismatch <= 0;
					end
					else
					begin
					Frame_drop <= 0;
					SFD_mismatch <= 0;
					end
				end
				else if((LatchedByte[7:4] == 'hd) & ByteCnt == 1)
				begin
					if(MRxErr)
					begin
					Frame_drop <= 1;
					SFD_mismatch <= 0;
					end
					else
					begin
					Frame_drop <= 0;
					SFD_mismatch <= 0;
					end
				end
				else 
				begin
					Frame_drop <= 1;
					SFD_mismatch <= 1;
				end
			end
		else 
		begin
			Frame_drop <= 0;
			Preamble_mismatch <= 0;
			SFD_mismatch <= 0;
		end
	end
end

assign GenerateRxValid = ((StateDA & Rx_NibCnt == 'd1)| (StateSA & Rx_NibCnt == 'd1) | (StateLength & Rx_NibCnt == 'd1)| StateData[1]);


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      RxValid_d1 <=  1'b0;
      RxValid   <=  1'b0;
    end
  else
    begin
      RxValid_d1 <=  GenerateRxValid;
      RxValid   <=  RxValid_d1;
	  
    end
end


assign GenerateRxStartFrm = (StateDA & Rx_NibCnt == 'd1) & ((ByteCntEq0 & ~DlyCrcEn)| ((DlyCrcCnt == 4'h3) & DlyCrcEn));	

always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      RxStartFrm_d <=  1'b0;
      RxStartFrm   <=  1'b0;
    end
  else
    begin
      RxStartFrm_d <=  GenerateRxStartFrm;
      RxStartFrm   <=  RxStartFrm_d;
    end
end



assign GenerateRxEndFrm = StateData[1] &
                          (~MRxDV & ByteCntGreat2 | ByteCntMaxFrame);	

assign DribbleRxEndFrm  = StateData[0] &  ~MRxDV & ByteCntGreat2;


always @ (posedge MRxClk or negedge Resetn)
begin
  if(Resetn == 0)
    begin
      RxEndFrm_d1 <=  1'b0;
      RxEndFrm    <=  1'b0;
    end
  else
    begin
      RxEndFrm_d1 <=  GenerateRxEndFrm;
      RxEndFrm    <=  RxEndFrm_d1 | DribbleRxEndFrm;
    end
end

//Added by the Moschip team on June 1st 2020
reg [3:0] MRxD_d;
reg MRxDV_d;


always@(posedge MRxClk or negedge Resetn)
begin
	if(!Resetn)
		MRxD_d <= 0;
	else
	begin
		MRxD_d <= MRxD;
	end
end

always@(posedge MRxClk or negedge Resetn)
begin
	if(!Resetn)
		MRxDV_d <= 0;
	else
	begin
		MRxDV_d <= MRxDV;
	end
end

//added code by Moschip Team on June 8th
always @(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
		Frame_Length <= 0;
	else
	begin
		if(StateLength)
		begin
			case(1)
			ByteCntEq0:begin   
						Frame_Length[15:8] <= {MRxD_d[3:0],Frame_Length[15:12]}; 
						end
			ByteCntEq1:begin   
						Frame_Length[7:0]  <= {MRxD_d[3:0],Frame_Length[7:4]}; 
					   end
			endcase
		end
	end
end

always @(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
	begin
		payld_gt_maxfl_error <= 0;
	end
	else
	begin
		if(StateData)
		begin
			if((frame_ByteCnt + 1) > MaxFL)
			begin
				if(HugEn == 0)
				begin
					payld_gt_maxfl_error <= 1;
				end
				else
					payld_gt_maxfl_error <= 0;
			end
			else
				payld_gt_maxfl_error <= 0;
		end
		else
			payld_gt_maxfl_error <= 0;
	end
end


always@(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
	begin
		py_gt_len_pad1_dat0 <= 1;
	end
	else
	begin
		if(StateData)
		begin
			if((ByteCnt > Frame_Length) && ByteCnt <= 'd46)
			begin
				if(Pad)
				begin
					case(StateData)
						2'b01:begin
								if(RxData_d[3:0] != 0)
								begin
									py_gt_len_pad1_dat0 <= 0;
								end
								else
								begin
									py_gt_len_pad1_dat0 <= py_gt_len_pad1_dat0 && 1'b1;
								end
							  end
						2'b10:begin
								if(RxData_d[7:4] != 0)
								begin
									py_gt_len_pad1_dat0 <= 0;
								end
								else
								begin
									py_gt_len_pad1_dat0 <= py_gt_len_pad1_dat0 && 1'b1;
								end
							  end
					endcase
				end
				else
					py_gt_len_pad1_dat0 <= 0;
			end
			else
			begin
				py_gt_len_pad1_dat0 <= 1; 
			end
		end
		else
			py_gt_len_pad1_dat0 <= 1; 
	end
end

always @(posedge MRxClk or negedge Resetn )
begin
    if(Resetn == 0) 
	begin 
		shift8_py_gt_len_pad1_dat0_f0 <= 1;
		shift8_py_gt_len_pad1_dat0_f1 <= 1;
		shift8_py_gt_len_pad1_dat0_f2 <= 1;
		shift8_py_gt_len_pad1_dat0_f3 <= 1;
		shift8_py_gt_len_pad1_dat0_f4 <= 1;
		shift8_py_gt_len_pad1_dat0_f5 <= 1;
		shift8_py_gt_len_pad1_dat0_f6 <= 1;
		shift8_py_gt_len_pad1_dat0_f7 <= 1;
	end
	else 
	begin
		shift8_py_gt_len_pad1_dat0_f0 <= py_gt_len_pad1_dat0;
		shift8_py_gt_len_pad1_dat0_f1 <= shift8_py_gt_len_pad1_dat0_f0;
		shift8_py_gt_len_pad1_dat0_f2 <= shift8_py_gt_len_pad1_dat0_f1;
		shift8_py_gt_len_pad1_dat0_f3 <= shift8_py_gt_len_pad1_dat0_f2;
		shift8_py_gt_len_pad1_dat0_f4 <= shift8_py_gt_len_pad1_dat0_f3;
		shift8_py_gt_len_pad1_dat0_f5 <= shift8_py_gt_len_pad1_dat0_f4;
		shift8_py_gt_len_pad1_dat0_f6 <= shift8_py_gt_len_pad1_dat0_f5;
		shift8_py_gt_len_pad1_dat0_f7 <= shift8_py_gt_len_pad1_dat0_f6;
	end
end
//

always@(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0) endframe_d <= 1'b0;
	else if(StateData[1] && MRxDV == 0) endframe_d <= 1'b1;
	else endframe_d <= 1'b0;
end

always@(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0) 
		endframe_d1 <= 1'b0;
	else
		endframe_d1 <= endframe_d;
end

//added code for length_vs_payload error
							
always@(posedge MRxClk or negedge Resetn)
begin
	if(Resetn == 0)
		Length_Vs_Payload_error <= 0;
	else
	begin
		if(endframe_d)
		begin
			case(1)
			(ByteCnt-4 == Frame_Length):begin
											if(CrcError == 0)
											begin
												if(frame_ByteCnt < r_MinFL)
												begin
													Length_Vs_Payload_error <= 1;		//drop frame
												end
												else if(frame_ByteCnt == r_MinFL)
												begin
													Length_Vs_Payload_error <= 0;	//accept frame
												end
												else if(frame_ByteCnt > r_MinFL)
												begin
													if(frame_ByteCnt <= MaxFL)	//FL <= MAXFL
													begin
														Length_Vs_Payload_error <= 0;	//accept frame
													end
													else if(frame_ByteCnt > MaxFL)
													begin
														if(HugEn == 0)
														begin
															Length_Vs_Payload_error <= 1; //drop frame
														end
														else
														begin
															Length_Vs_Payload_error <= 0;
														end
													end
												end
											end
											else
												Length_Vs_Payload_error <= 1;		//drop frame
									    end
			(ByteCnt-4 > Frame_Length):begin
											if(Pad)
											begin
												if(RxEndFrm_d1)
												begin
													if(shift8_py_gt_len_pad1_dat0_f5)	
													begin	
														if(CrcError)
															begin
															Length_Vs_Payload_error <= 1;		//drop frame
															end
														else
														begin
															if(frame_ByteCnt == r_MinFL)
															begin
																Length_Vs_Payload_error <= 0;
															end
															else
															begin
																Length_Vs_Payload_error <= 1;		//drop frame
															end
														end
													end
													else
														Length_Vs_Payload_error <= 1;		//drop frame
												end
												else
													Length_Vs_Payload_error <= 0;
											end
											else
												Length_Vs_Payload_error <= 1;		//drop frame
									   end
			(ByteCnt-4 < Frame_Length):begin
											Length_Vs_Payload_error <= 1;		//drop frame
									   end							
			endcase
		end	
		else
			Length_Vs_Payload_error <= 0;
	end
end	

endmodule

