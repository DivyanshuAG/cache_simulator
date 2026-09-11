`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Divyanshu Agarwal
// 
// Create Date: 09/10/2026 10:39:57 PM
// Design Name: 
// Module Name: L1_tlb
// Project Name: 
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


module L1_tlb(
    input clk, reset, enable, input [2:0] pid, input [31:0] virtual_addr,
    input frame_inp_ready, input [15:0] frame_from_mem,
    output reg hit, output [25:0] paddr

);
    reg [2:0] pids [0:31];
    reg [7:0] segment_num [0:31];
    reg [13:0] page_num [0:31];
    reg [15:0] frame_num [0:31];
    reg valid [0:31];

    reg [4:0] lru [0:31];

    wire [7:0] current_segment = virtual_addr[31:24];
    wire [13:0] current_page = virtual_addr[23:10];
    wire [9:0] offset = virtual_addr[9:0];

    reg [15:0] hit_frame;
    reg [4:0] hit_index;
    reg [4:0] lru_eviction;
    reg [4:0] target;

    integer a;
    always @(*) begin
        hit = 0;
        hit_frame = 0;
        hit_index = 0;
        target = 0;
        for (a=31; a>=0; a=a-1) begin
            if (lru[a] == 0) target = a;
            if (!valid[a]) target = a;
            if (valid[a] && segment_num[a] == current_segment && page_num[a] == current_page && pids[a] == pid) begin
                hit = 1;
                hit_frame = frame_num[a];
                hit_index = a;
            end
        end
    end
    assign paddr = {hit_frame, offset};

    integer i;
    always @(posedge clk) begin
        if (!reset) begin
            for (i = 0; i<32; i=i+1) begin
                pids[i] <= 0;
                segment_num[i] <= 0;
                page_num[i] <= 0;
                frame_num[i] <= 0;
                valid[i] <= 0;
                lru[i] <= 0;
            end
        end else if (enable) begin
            if (hit) begin
                for (i = 0; i < 32; i = i + 1) begin
                    if (i == hit_index) lru[i] <= 5'd31;
                    else if (lru[i] > 0) lru[i] <= lru[i] - 1;
                end
            end else if (frame_inp_ready) begin
                valid[target] <= 1;
                pids[target] <= pid;
                segment_num[target] <= current_segment;
                page_num[target] <= current_page;
                frame_num[target] <= frame_from_mem;

                for (i = 0; i < 32; i=i+1) begin
                    if (i == target) lru[i] <= 5'd31;
                    else if (lru[i] > 0) lru[i] <= lru[i] - 1;
                end
            end
        end
    end
endmodule