`timescale 1ns / 1ps

module test_main;

parameter SAMPLE_RATE = 44100; // Hz
parameter CLK_MULTIPLIER = 64;
parameter CLK_HZ = SAMPLE_RATE * CLK_MULTIPLIER;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter NUM_SAMPLES = 44100;

logic clk;

logic [15:0] sample_in;
wire [15:0] sample_out;

main UUT (
    clk, sample_in, sample_out
);

always #(CLK_PERIOD_NS/2) clk = ~clk;

logic [63:0] cycles = 0;
logic [63:0] cycles_to_run = (CLK_HZ/1); // Run for 1000ms
logic [63:0] sample_idx = 0;

reg [15:0] audio_samples[0:NUM_SAMPLES-1];

logic [5:0] count = 6'b0;
wire sample_clk = count[5];
real progress = 0.0;

always_ff @(posedge clk)
    count <= count + 1;

always_ff @(posedge sample_clk) begin
    sample_in <= audio_samples[sample_idx];
    sample_idx++;
end


initial begin
    $readmemh("memories/sine_samples_pulse.memh", audio_samples);

    $dumpfile("main.fst");
    $dumpvars;
    $display("Running test main...");

    clk = 0;
    $display("Running for %d clock cycles. ", cycles_to_run);
    repeat (cycles_to_run) begin
        @(posedge clk);
        progress = cycles++/(1.0*cycles_to_run);
    end
    $finish;
end

always #50_000_000 $display("Test progress: %.1f%%", 100*progress);

endmodule