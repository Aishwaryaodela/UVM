`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:48 06/07/2020 
// Design Name: 
// Module Name:    eth_clockgen 
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
module eth_clockgen(Clk, Resetn, Divider, MdcEn, MdcEn_n, Mdc);

input       Clk;              // Input clock (Host clock)
input       Resetn;            // Resetn signal
input [7:0] Divider;          // Divider (input clock will be divided by the Divider[7:0])

output      Mdc;              // Output clock
output      MdcEn;            // Enable signal is asserted for one Clk period before Mdc rises.
output      MdcEn_n;          // Enable signal is asserted for one Clk period before Mdc falls.

reg         Mdc;
reg   [7:0] Counter;

wire        CountEq0;
wire  [7:0] CounterPreset;
wire  [7:0] TempDivider;


assign TempDivider[7:0]   = (Divider[7:0]<2)? 8'h02 : Divider[7:0]; // If smaller than 2
assign CounterPreset[7:0] = (TempDivider[7:0]>>1) - 8'b1;           // We are counting half of period


// Counter counts half period
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    Counter[7:0] <=  8'h1;
  else
    begin
      if(CountEq0)
        begin
          Counter[7:0] <=  CounterPreset[7:0];
        end
      else
        Counter[7:0] <=  Counter - 8'h1;
    end
end


// Mdc is asserted every other half period
always @ (posedge Clk or negedge Resetn)
begin
  if(Resetn == 0)
    Mdc <=  1'b0;
  else
    begin
      if(CountEq0)
        Mdc <=  ~Mdc;
    end
end


assign CountEq0 = Counter == 8'h0;
assign MdcEn = CountEq0 & ~Mdc;
assign MdcEn_n = CountEq0 & Mdc;

endmodule



