`timescale 1ns / 1ps

module maze#(
    parameter CLK_FREQ = 100_000_000,   // System clock frequency in Hz.
    parameter KEY_FILTER_DELAY = 10,    // Key debouncer delay.
    parameter SEGS_FLASH_INT = 100      // Segment display flash interval on winning in ms.
)(
    input sys_clk,                      // System clock.
    input sys_rst,                      // System reset. High active.
    input btnu0, btnd0, btnl0, btnr0,   // Player controls. High active.
    input mapl0, mapr0,                 // Map controls. High active.
    output reg [7:0] leds,              // LEDs. High active. 
    output reg [6:0] segs               // LED segments. High active.
);

    // Key debouncers
    wire btnu, btnd, btnl, btnr, mapl, mapr;
    key_filter #(.CLK_FREQ(CLK_FREQ), .DELAY(KEY_FILTER_DELAY)) key_filter_inst0 (.clk(sys_clk), .rst(sys_rst), .key_in(btnu0), .key_pos(btnu));
    key_filter #(.CLK_FREQ(CLK_FREQ), .DELAY(KEY_FILTER_DELAY)) key_filter_inst1 (.clk(sys_clk), .rst(sys_rst), .key_in(btnd0), .key_pos(btnd));
    key_filter #(.CLK_FREQ(CLK_FREQ), .DELAY(KEY_FILTER_DELAY)) key_filter_inst2 (.clk(sys_clk), .rst(sys_rst), .key_in(btnl0), .key_pos(btnl));
    key_filter #(.CLK_FREQ(CLK_FREQ), .DELAY(KEY_FILTER_DELAY)) key_filter_inst3 (.clk(sys_clk), .rst(sys_rst), .key_in(btnr0), .key_pos(btnr));
    key_filter #(.CLK_FREQ(CLK_FREQ), .DELAY(KEY_FILTER_DELAY)) key_filter_inst5 (.clk(sys_clk), .rst(sys_rst), .key_in(mapl0), .key_pos(mapl));
    key_filter #(.CLK_FREQ(CLK_FREQ), .DELAY(KEY_FILTER_DELAY)) key_filter_inst6 (.clk(sys_clk), .rst(sys_rst), .key_in(mapr0), .key_pos(mapr));

    // Maze & player status
    // maze_rom[i][j],  i: Row in mem (T0 -> B7), j: Col in mem (R0 -> L7)
    reg [7:0] maze_rom [0:7];
    initial $readmemb("maze_data.mem", maze_rom);
    reg [2:0] player_x, player_y, view_x;   // player_x: Row (i), player_y: Column (j), view_x: Currently displayed row (i)
    wire [7:0] maze_row;
    assign maze_row = maze_rom[view_x];
    wire win_flag;
    assign win_flag = (player_x == 7 && player_y == 7);

    // Maze row control
    always @(posedge sys_clk)
        if (sys_rst) begin;
            view_x <= 0;
        end else if (mapl && view_x > 0)
            view_x <= view_x - 1;
        else if (mapr && view_x < 7)
            view_x <= view_x + 1;

    // Player control
    always @(posedge sys_clk) 
        if (sys_rst) begin
            player_x <= 0;
            player_y <= 0;
        end else if (btnl && player_x > 0 && !maze_rom[player_x - 1][player_y])
            player_x <= player_x - 1;
        else if (btnr && player_x < 7 && !maze_rom[player_x + 1][player_y])
            player_x <= player_x + 1;
        else if (btnd && player_y > 0 && !maze_rom[player_x][player_y - 1])
            player_y <= player_y - 1;
        else if (btnu && player_y < 7 && !maze_rom[player_x][player_y + 1])
            player_y <= player_y + 1;

    // PWM counter for dim display of maze wall
    localparam PWM_CNT_MAX = CLK_FREQ / 200;
    localparam PWM_W_CNT_MAX = PWM_CNT_MAX / 25;
    reg [$clog2(PWM_CNT_MAX) - 1:0] pwm_cnt = 0;
    reg pwm_w;
    always @(posedge sys_clk)
        if(sys_rst || pwm_cnt == PWM_CNT_MAX - 1)
            pwm_cnt <= 0;
        else
            pwm_cnt <= pwm_cnt + 1;
    always @(posedge sys_clk)
        if(sys_rst || pwm_cnt >= PWM_W_CNT_MAX)
            pwm_w <= 0;
        else
            pwm_w <= 1;

    // Player + maze display
    function logic led_tmp(input [2:0] i);
        // Player -> bright
        if (player_x == view_x && player_y == i)
            led_tmp = 1;
        // Wall -> dim
        else if (maze_row[i]) 
            led_tmp = pwm_w;
        // Road -> off
        else
            led_tmp = 0;
    endfunction
    always @(posedge sys_clk)
        if (sys_rst)
            leds <= 0;
        else
            leds <= {
                led_tmp(7),led_tmp(6),led_tmp(5),led_tmp(4),
                led_tmp(3),led_tmp(2),led_tmp(1),led_tmp(0)
            };

    // Segment display of maze column number
    reg segs_en;
    wire [3:0] segs_data;
    assign segs_data = {1'b0, view_x};
    segs_disp segs_disp_inst(.clk(sys_clk), .en(segs_en), .data(segs_data), .segs(segs));
    localparam SEGS_FLASH_CNT_MAX = SEGS_FLASH_INT * CLK_FREQ / 100;
    reg [$clog2(SEGS_FLASH_CNT_MAX) - 1:0] segs_flash_cnt = 0;
    always @(posedge sys_clk or posedge sys_rst)
        if (sys_rst) begin
            segs_flash_cnt <= 0;
            segs_en <= 1;
        end
        else if (segs_flash_cnt == SEGS_FLASH_CNT_MAX - 1) begin
            segs_flash_cnt <= 0;
            segs_en <= ~win_flag | ~segs_en;
        end
        else
            segs_flash_cnt <= segs_flash_cnt + 1;

endmodule
