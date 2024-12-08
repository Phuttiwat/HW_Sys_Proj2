`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2024 12:40:40
// Design Name: 
// Module Name: system
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


module system(
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output JA_0, //uart TX
    input JA_1, //uart RX
    input [7:0] sw, 
    input btnC, //push data
    input btnU,
    input btnL,
    input btnR,
    input btnD,
    input reset,
    input set,
    input clk,
    output hsync, vsync,    // VGA connector
    output [11:0] rgb      // Combined RGB signal
    );
    
    wire [7:0] last_valid_data;
    wire new_data; // Signal indicating new data received
    wire tdmClk;
    clkDividerN #(19) tdmClkDivider(tdmClk, clk);
    
    // UART
    uart_rs232 uart(
        .last_valid_data(last_valid_data),
        .RsTx(JA_0),
        .RsRx(JA_1),
        .clk(clk),
        .data_to_send(sw),
        .send_signal(btnC),
        .new_data(new_data) // Connect the new_data signal
    );
    
    // VGA
    top(
        .clk(clk),
        .reset(reset),
        .last_valid_data(last_valid_data[6:0]),
        .new_data(new_data),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    
    // Seven Segment
    reg [7:0] char3,char2,char1,char0; // left to right
    
    wire an0,an1,an2,an3; // anode for seven-segment
    assign an={an3,an2,an1,an0};
    
    // Seven Segment Module
    quadSevenSeg sevenSegment(seg,dp,an0,an1,an2,an3,char0,char1,char2,char3,tdmClk);
    
    // Segment Data Changes
    always @(posedge tdmClk) begin
        if (btnC) char0 = sw;
        char1 = last_valid_data;
    end
    
endmodule
