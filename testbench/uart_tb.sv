`timescale 1ns / 1ps

module uart_tb;

    parameter CLKS_PER_BIT = 87;
    parameter CLK_PERIOD = 100;       // Clock period
    parameter PERIOD_OF_BIT = 8700;   // Period for one bit in the UART
    parameter BITS_AMOUNT = 8;        // Number of bits for data transmission (8 data bits)
    
    logic clk;
    
    logic data_ready_tx;
    logic [7:0] byte_trans_tx;
    logic trans_active_tx;
    logic data_out_tx;
    logic done_sig_tx;
    
    logic data_in_rx;
    logic [7:0] byte_recv_rx;
    logic recv_valid_rx;
    
    //Monitor signals
    logic error_sig = 0;
    logic success_sig = 0;
    
    // Clock signal generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end
    
    // UART transmitter and receiver instances
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
        .clk(clk),
        .data_ready(data_ready_tx),
        .byte_trans(byte_trans_tx),
        .trans_active(trans_active_tx),
        .data_out(data_out_tx),
        .done_sig(done_sig_tx)
    );
    
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
        .clk(clk),
        .data_in(data_out_tx),
        .byte_recv(byte_recv_rx),
        .recv_valid(recv_valid_rx)
    );
    
    // Stimulus for data transfer
    initial begin
        data_ready_tx = 0;
        #(PERIOD_OF_BIT * BITS_AMOUNT);
        #(PERIOD_OF_BIT * BITS_AMOUNT);
        repeat(100) begin
            @(posedge clk);
            byte_trans_tx <= $urandom_range(0, 255); // Generation of random data for transmission
            
            // Activate transmission
            data_ready_tx <= 1;
            @(posedge clk);
            data_ready_tx <= 0;
            
            wait(recv_valid_rx); // Waiting for data reception to complete
            
            // Waiting between transmissions. Added for easier visual analysis on the waveform. Does not affect data reception in any way.
            #(PERIOD_OF_BIT * BITS_AMOUNT);
        end
        @(posedge clk);
        $stop;
    end
    
    typedef struct { 
        logic [7:0] byte_trans_tx_S2;
        logic [7:0] byte_recv_rx_S2;
    } packet;
    
    mailbox#(packet) mon2chk = new();
    
    // Monitoring of data transmission
    initial begin
        packet pkt;
        forever begin
            @(posedge clk);
            pkt.byte_trans_tx_S2 = byte_trans_tx;
            pkt.byte_recv_rx_S2  = byte_recv_rx; 
            mon2chk.put(pkt);
        end
    end
    
    // Checking of results
    initial begin
        packet pkt_prev, pkt_cur;
        mon2chk.get(pkt_prev); // Capture the first state
        forever begin
            
            mon2chk.get(pkt_cur); // Capture the current state

            error_sig = 0;
            success_sig = 0;
            
            // Waiting for admission to be finalized
            if (done_sig_tx == 1'b1) begin
                // Comparison of transmitted and received data
                if (pkt_cur.byte_recv_rx_S2 != pkt_prev.byte_trans_tx_S2) begin
                    error_sig = 1;  
                    $display("ERROR: byte_trans_tx = %d, byte_recv_rx = %d \n", pkt_prev.byte_trans_tx_S2, pkt_cur.byte_recv_rx_S2);
                    $error("Mismatch detected \n");
                end else if (pkt_cur.byte_recv_rx_S2 == pkt_prev.byte_trans_tx_S2) begin
                    success_sig = 1;
                    $display("SUCCESS: byte_trans_tx = %d, byte_recv_rx = %d \n", pkt_prev.byte_trans_tx_S2, pkt_cur.byte_recv_rx_S2);
                end
            end
            
            @(posedge clk);
                        
            pkt_prev = pkt_cur;
        end
    end
endmodule
 




