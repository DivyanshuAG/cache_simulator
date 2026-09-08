`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Divyanshu Agarwal
// Engineer: 
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
    output reg [15:0] totalL1Hit, totalL1Miss
    );
    wire L1hit, L1miss;
    
    reg [14:0] tag_w0 [0:127];
    reg [14:0] tag_w1 [0:127];
    reg [14:0] tag_w2 [0:127];
    reg [14:0] tag_w3 [0:127];

    reg valid_w0 [0:127];
    reg valid_w1 [0:127];
    reg valid_w2 [0:127];
    reg valid_w3 [0:127];

    reg [15:0] lru[0:127];

    wire [14:0] tag = paddr[25:11];
    wire [6:0] index = paddr[10:4];
    wire [3:0] offset = paddr[3:0];

    wire hit_w0 = valid_w0[index] && (tag == tag_w0[index]); 
    wire hit_w1 = valid_w1[index] && (tag == tag_w1[index]); 
    wire hit_w2 = valid_w2[index] && (tag == tag_w2[index]); 
    wire hit_w3 = valid_w3[index] && (tag == tag_w3[index]);

    assign L1hit = hit_w0 | hit_w1 | hit_w2 | hit_w3;
    assign L1miss = ~L1hit;

    wire empty_w0 = ~valid_w0[index];
    wire empty_w1 = ~valid_w1[index];
    wire empty_w2 = ~valid_w2[index];
    wire empty_w3 = ~valid_w3[index];

    wire [1:0] lru_eviction = ((lru[index] & 16'h000f)==16'h0000) ? 2'b00: ((lru[index] & 16'h00f0)==16'h0000) ? 2'b01 : ((lru[index] & 16'h0f00)==16'h0000) ? 2'b10 : 2'b11;

    wire [1:0] target = empty_w0 ? 2'b00 : empty_w1 ? 2'b01 : empty_w2 ? 2'b10 : empty_w3 ? 2'b11 : lru_eviction;

    integer i;
    always @(posedge clk) begin
        if (!reset) begin
            for (i = 0; i<128; i=i+1) begin
                valid_w0[i] <= 0;
                valid_w1[i] <= 0;
                valid_w2[i] <= 0;
                valid_w3[i] <= 0;
                lru[i] <= 0;
            end
            totalL1Hit <= 0;
            totalL1Miss <= 0;
        end else if (enable) begin
            if (L1hit) begin
                totalL1Hit <= totalL1Hit + 1;
                if (hit_w0) lru[index] <= (lru[index] | 16'h000f) & ~16'h1111;
                else if (hit_w1) lru[index] <= (lru[index] | 16'h00f0) & ~16'h2222;
                else if (hit_w2) lru[index] <= (lru[index] | 16'h0f00) & ~16'h4444;
                else if (hit_w3) lru[index] <= (lru[index] | 16'hf000) & ~16'h8888;
            end else begin
                totalL1Miss <= totalL1Miss + 1;
                case (target)
                    2'b00: begin
                        tag_w0[index] <= tag; valid_w0[index] <= 1;
                        lru[index] <= (lru[index] | 16'h000f) & ~16'h1111;
                        end
                    2'b01: begin
                        tag_w1[index] <= tag; valid_w1[index] <= 1;
                        lru[index] <= (lru[index] | 16'h00f0) & ~16'h2222;
                        end
                    2'b10: begin
                        tag_w2[index] <= tag; valid_w2[index] <= 1;
                        lru[index] <= (lru[index] | 16'h0f00) & ~16'h4444;
                        end
                    2'b11: begin
                        tag_w3[index] <= tag; valid_w3[index] <= 1;
                        lru[index] <= (lru[index] | 16'hf000) & ~16'h8888;
                        end
                endcase
            end
        end
    end
endmodule