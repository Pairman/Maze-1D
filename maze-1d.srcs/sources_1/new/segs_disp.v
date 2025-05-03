module segs_disp (
    input clk,              // Clock.
    input en,               // On-off switch. High active.
    input [6:0] data,       // Input data
    output reg [6:0] segs   // LED segments. High active.
);

    always @(posedge clk)
        if (en)
            case (data[3:0])
                4'h0: segs = 7'b0000001;
                4'h1: segs = 7'b1001111;
                4'h2: segs = 7'b0010010;
                4'h3: segs = 7'b0000110;
                4'h4: segs = 7'b1001100;
                4'h5: segs = 7'b0100100;
                4'h6: segs = 7'b0100000;
                4'h7: segs = 7'b0001111;
                4'h8: segs = 7'b0000000;
                4'h9: segs = 7'b0000100;
                4'hA: segs = 7'b0001000;
                4'hb: segs = 7'b1100000;
                4'hC: segs = 7'b0110001;
                4'hd: segs = 7'b1000010;
                4'hE: segs = 7'b0110000;
                4'hF: segs = 7'b0111000;
                default: segs = 7'b1111111;
            endcase
        else
            segs = 7'b1111111;

endmodule
