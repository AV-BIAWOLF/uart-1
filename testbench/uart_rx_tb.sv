`timescale 1ns / 1ps

module uart_tb;
    parameter CLKS_PER_BIT = 87;
    
    reg clk;
    reg data_in;
    wire [7:0] byte_recv;
    wire recv_valid;
    
    uart_rx #(.CLKS_PER_BIT(87)) uut (
        .clk(clk),
        .data_in(data_in),
        .byte_recv(byte_recv),
        .recv_valid(recv_valid)
    );
    
    // Clock generation
    always #1 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        data_in = 1;
        
        // Wait for the initial reset
        #10;
        
        // Simulate start bit (0)
        data_in = 0;
        #174; // Wait for 10 clock cycles (87*10ns) for a bit width at 10 MHz

        // Simulate data bits (e.g., 8'b10101010)
        data_in = 1; #174;  // 1st bit
        data_in = 0; #174;  // 2nd bit
        data_in = 1; #174;  // 3rd bit
        data_in = 0; #174;  // 4th bit
        data_in = 1; #174;  // 5th bit
        data_in = 0; #174;  // 6th bit
        data_in = 1; #174;  // 7th bit
        data_in = 0; #174;  // 8th bit
        
        // Simulate stop bit (1)
        data_in = 1;
        #174;
        
        // End simulation
        #100;
        $finish;
    end

    // Monitor for debug
    initial begin
        $monitor("Time: %0d, byte_recv: %b, recv_valid: %b", $time, byte_recv, recv_valid);
    end
    
endmodule
