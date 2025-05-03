`timescale 1ns / 1ps

// https://verimake.com/d/513-fpga
module key_filter #(
    parameter CLK_FREQ = 100_000_000,   // System clock frequency in Hz.
    parameter DELAY    = 20             // ms
) (
    input  wire clk,        // Clock.
    input  wire rst,        // Reset. High active
    input  wire key_in,     // Input. High active
    output reg  key_out,    // Debounced output. High active
    output reg  key_pos     // Key_out active event. High active
);

    localparam CNT_MAX = (DELAY * CLK_FREQ / 1000);
    reg [$clog2(CNT_MAX) - 1 : 0] cnt;
    reg key_in_r;
    reg key_out_r;
    wire key_changed;

    // Save the last key_in
    always @(posedge clk or posedge rst)
        if (rst)
            key_in_r <= 0;
        else
            key_in_r <= key_in;

    // Whether key_in changed
    assign key_changed = key_in ^ key_in_r;

    // Counter
    always @(posedge clk or posedge rst)
        if (rst)
            cnt <= 0;
        // Reset on key change / bounce
        else if (key_changed)
            cnt <= 0;
        else if (cnt <= CNT_MAX - 1)
            cnt <= cnt + 1;

    // Update key_out_r
    always @(posedge clk or posedge rst)
        if (rst)
            key_out_r <= 0;
        else
            key_out_r <= key_out;

    // Update key_out
    always @(posedge clk or posedge rst)
        if (rst) begin
            key_out <= 0;
        end else if (cnt == CNT_MAX - 1) begin
            key_out <= key_in_r;
        end

    // Update key_pos
    always @(posedge clk or posedge rst)
        if (rst)
            key_pos <= 0;
        else
            key_pos <= (~key_out_r) & key_out;

endmodule
