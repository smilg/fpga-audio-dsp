/*
This is an ***untested*** (read: probably does not work!) module for interfacing with the ISSI IS61WV5128BLL-10BLI SRAM chip on
the Digilent Cmod A7 boards used in class. The datasheet for the SRAM is here: https://www.issi.com/WW/pdf/61-64WV5128Axx-Bxx.pdf

If this project were to be continued, the SRAM would store the circular buffer used for delay. With 524288 words of 8 bits, 262144
16-bit audio samples can be stored, which amounts to a maximum delay of ~5.9 seconds.
*/

`timescale 1ns/1ps
`default_nettype none

module sram_interface(clk, rd_addr, rd_data, wr_ena, wr_addr, wr_data, mem_addr, data, w_en, o_en, c_en);

input wire clk;
input wire [18:0] rd_addr;
output logic [7:0] rd_data;

input wire [18:0] wr_addr;
input wire [7:0] wr_data;
input wire wr_ena;

output logic [18:0] mem_addr;
inout logic [7:0] data;
output logic o_en, w_en, c_en;    // active low

// if we aren't writing to the SRAM, let the data lines
// float so the sram can drive them 
assign data = wr_ena ? wr_data : 8'bz;
always_comb begin
    w_en = ~wr_ena;
    mem_addr = wr_ena ? wr_addr : rd_addr;
    o_en = 0;
    c_en = 0;
end

always_ff @(posedge clk) begin
    if(wr_ena) begin
        rd_data <= data;
    end
end

endmodule