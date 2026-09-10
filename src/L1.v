`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Divyanshu Agarwal 
// 
// Create Date: 09/07/2026 03:44:17 PM
// Design Name: 
// Module Name: L1
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


module L1(
    input clk, reset, enable, input [25:0] paddr,
    output reg [15:0] totalhit, totalL1Miss
    );
    reg hit;
    
    reg [14:0] tag_array [0:127][0:3];
    reg valid [0:127][0:3];

    reg [15:0] lru[0:127];

    wire [14:0] tag = paddr[25:11];
    wire [6:0] index = paddr[10:4];
    wire [3:0] offset = paddr[3:0];

    wire [1:0] lru_eviction = ((lru[index] & 16'h000f)==16'h0000) ? 2'b00: ((lru[index] & 16'h00f0)==16'h0000) ? 2'b01 : ((lru[index] & 16'h0f00)==16'h0000) ? 2'b10 : 2'b11;

    reg [1:0] hit_way, target;

    integer a;
    always @(*) begin
        hit = 0;
        target = lru_eviction;
        hit_way = 0;
        
        for (a=3; a>=0; a=a-1) begin
            if (valid[index][a] && tag_array[index][a] == tag) begin
                hit = 1;
                hit_way = a;
            end
            if (!valid[index][a]) target = a;
        end
    end

    integer i, j;
    always @(posedge clk) begin
        if (!reset) begin
            for (i = 0; i<128; i=i+1) begin
                for (j = 0; j<4; j=j+1) begin
                    valid[i][j] <= 0;
                end
                lru[i] <= 0;
            end
            totalhit <= 0;
            totalL1Miss <= 0;
        end else if (enable) begin
            if (hit) begin
                totalhit <= totalhit + 1;
                case (hit_way)
                    2'b00: lru[index] <= (lru[index] | 16'h000f) & ~16'h1111;
                    2'b01: lru[index] <= (lru[index] | 16'h00f0) & ~16'h2222;
                    2'b10: lru[index] <= (lru[index] | 16'h0f00) & ~16'h4444;
                    2'b11: lru[index] <= (lru[index] | 16'hf000) & ~16'h8888;
                endcase
            end else begin
                totalL1Miss <= totalL1Miss + 1;
                valid[index][target] <= 1;
                tag_array[index][target] <= tag;
                case (target)
                    2'b00: lru[index] <= (lru[index] | 16'h000f) & ~16'h1111;
                    2'b01: lru[index] <= (lru[index] | 16'h00f0) & ~16'h2222;
                    2'b10: lru[index] <= (lru[index] | 16'h0f00) & ~16'h4444;
                    2'b11: lru[index] <= (lru[index] | 16'hf000) & ~16'h8888;
                endcase
            end
        end
    end
endmodule