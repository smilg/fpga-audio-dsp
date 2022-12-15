`timescale 1ns / 1ps
`default_nettype none

module main(
  sysclk, sample_in, sample_out
);

input logic signed [15:0] sample_in;
output logic signed [15:0] sample_out = 0;

input wire sysclk;

logic [15:0] rd_addr = 16'd2;
logic [15:0] rd_data;
logic [15:0] wr_addr = 16'b0;
logic [15:0] wr_data;
logic wr_ena;

block_ram #(.W(16), .L(65536)) SRAM(
  .clk(sysclk), .rd_addr(rd_addr), .rd_data(rd_data),
  .wr_ena(wr_ena), .wr_addr(wr_addr), .wr_data(wr_data)
);

logic [5:0] count = 6'b0;
wire sample_clk = count[5];

logic signed [15:0] sample_out_buffer = 16'b0;
logic [15:0] buffer_length = 16'd8820;  // buffer_length=seconds of delay*44100*2

always_ff @(posedge sysclk)
    count <= count + 1;

enum logic [1:0] {S_IDLE, S_WRITE, S_READ, S_GAIN} state = S_IDLE;

always_ff @(posedge sample_clk) begin
    state <= S_WRITE;
    sample_out <= sample_out_buffer;
end

always_ff @(posedge sysclk) begin
    case (state)
        S_WRITE : begin
            if(wr_addr >= buffer_length) // loop buffer around to 0 if end is reached
                wr_addr <= 16'b0;
            else    // otherwise increment by 1
                wr_addr <= wr_addr + 1;
            state <= S_READ;
        end
        S_READ : begin
            sample_out_buffer <= rd_data;
            if(rd_addr >= buffer_length)
                rd_addr <= 16'b0;
            else
                rd_addr <= rd_addr + 1;
            state <= S_GAIN;
        end
        S_GAIN : begin
            sample_out_buffer <= (sample_out_buffer >>> 2) + sample_in;
            state <= S_IDLE;
        end
        default : ;
    endcase 
end

always_comb begin
    case (state)
        S_WRITE : begin
            wr_ena = 1;
            wr_data = sample_in + sample_out;
        end
        default : begin
            wr_ena = 0;
            wr_data = 16'b0;
        end
    endcase
end

endmodule
