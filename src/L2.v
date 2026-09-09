`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Divyanshu Agarwal 
// 
// Create Date: 09/08/2026 10:17:54 PM
// Design Name: 
// Module Name: L2
// Project Name: Cache Simulator
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module L2(
    input clk, reset, enable, input [25:0] paddr,
    output reg [15:0] totalL2Hit, totalL2Miss
    );
    reg [3:0] fifo [0:63];
    reg [14:0] tag_array [0:63][0:15];
    reg valid [0:63][0:15];

    wire [14:0] tag = paddr[25:11];
    wire [5:0] index = paddr[10:5];
    wire [4:0] offset = paddr[4:0];

    reg hit;
    reg [3:0] target;

    integer a;
    always @(*) begin
        hit = 0;
        target = fifo[index];

        for (a=15; a>=0; a=a-1) begin
            if (valid[index][a] && tag_array[index][a] == tag) begin
                hit = 1;
            end
            if (!valid[index][a]) target = a;
        end
    end
    integer i, j;
    always @(posedge clk) begin
        if (!reset) begin
            for (i = 0; i<64; i=i+1) begin
                fifo[i] <= 0;
                for (j=0; j<16; j=j+1) begin
                    valid[i][j] <= 0;
                    tag_array[i][j] <= 0;
                end
            end
            totalL2Hit <= 0;
            totalL2Miss <= 0;
        end else if (enable) begin
            if (hit) begin
                totalL2Hit <= totalL2Hit + 1;
            end else begin
                totalL2Miss <= totalL2Miss + 1;
                valid[index][target] <= 1;
                tag_array[index][target] <= tag;
                fifo[index] <= fifo[index] + 1;
            end
        end
    end
endmodule