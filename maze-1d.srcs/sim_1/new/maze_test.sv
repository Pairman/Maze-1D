`timescale 1ns / 1ns

module maze_tb;

    localparam CLK_FREQ = 100; // MHz
    localparam CLK_PERIOD = 10; // ns
    localparam MS = 1_000_000; // 1ms = 1000000ns

    reg sys_clk;
    reg sys_rst;
    reg btnu0, btnd0, btnl0, btnr0, btnc0, mapl0, mapr0;
    wire [7:0] leds;
    wire [6:0] segs;

    maze #(
        .CLK_FREQ(CLK_FREQ * 1_000_000),
        .KEY_FILTER_DELAY(10),
        .SEGS_FLASH_INT(100)
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .btnu0(btnu0), .btnd0(btnd0), .btnl0(btnl0), .btnr0(btnr0), .btnc0(btnc0),
        .mapl0(mapl0), .mapr0(mapr0),
        .leds(leds),
        .segs(segs)
    );

    initial sys_clk = 0;
    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

    initial begin
        btnu0 = 0; btnd0 = 0; btnl0 = 0; btnr0 = 0; btnc0 = 0;
        mapl0 = 0; mapr0 = 0;

        sys_rst = 1;
        #(1 * MS)
        sys_rst = 0;
        #(1 * MS);

        // Player move up
        btnu0 = 1;
        #(15 * MS);
        btnu0 = 0;
        #(15 * MS);
        // Player move down
        btnd0 = 1;
        #(15 * MS);
        btnd0 = 0;
        #(15 * MS);
        // Player move right
        btnr0 = 1;
        #(15 * MS);
        btnr0 = 0;
        #(15 * MS);
        // Player move left
        btnl0 = 1;
        #(15 * MS);
        btnl0 = 0;
        #(15 * MS);

        // Map scroll right
        mapr0 = 1;
        #(15 * MS);
        mapr0 = 0;
        #(15 * MS);
        // Map scroll left
        mapl0 = 1;
        #(15 * MS);
        mapl0 = 0;
        #(15 * MS);

        $finish;
    end

endmodule
