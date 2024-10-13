`timescale 1ns / 1ps

// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_tx 
//    #(parameter CLKS_PER_BIT=87)
//    #(parameter CLKS_PER_BIT=868)
    #(parameter CLKS_PER_BIT = 217)
    (
        input clk,                  // clock signal
        input data_ready,           // data are ready for transmission
        input [7:0] byte_trans,     // data byte for transmission
        output trans_active,        // transmission is an active
        output reg data_out,        // transmission bits of data
        output done_sig             // transmission is done
    );
  
    
    (* MARK_DEBUG = "TRUE" *) logic [7:0] counter_TX = 0;
    reg [2:0] index = 0;
    reg       trans_active_reg = 0;
    reg [7:0] byte_trans_reg;
    reg       done_reg = 0;
    
    // Coding of a column automaton through a binary code   
    enum reg[4:0] {
        waiting = 5'b00001,
        start = 5'b00010,
        trans_data = 5'b00100,
        stop = 5'b01000,
        done = 5'b10000        
    } state;
   
   
   
    // FSM  
    always @(posedge clk) begin
        data_out <= 1;
        done_reg <= 0;
        case(state) 
            
            waiting: 
                begin
                    if (data_ready) state <= start;
                    else state <= waiting;
                end
                
            start:
                begin
                    data_out <= 0;                      // start bit is starting for beginnig transmission
//                    if (counter_TX < CLKS_PER_BIT) begin   // waiting clocks for transmission the first start bit
                    if (counter_TX < 8'd87) begin   // waiting clocks for transmission the first start bit
                        counter_TX <= counter_TX + 1;
                        byte_trans_reg <= byte_trans;
                        state <= start;
                    end
                    else begin
                        counter_TX <= 0;
                        state <= trans_data;
                        trans_active_reg <= 1;
                    end
                end
            
            trans_data:
                begin
                    data_out <= byte_trans_reg[index];  // Transmit the current data bit
//                    if (counter_TX < CLKS_PER_BIT) begin
                    if (counter_TX < 8'd87) begin
                        counter_TX <= counter_TX + 1;         // Wait for the current bit to complete
                    end
                    else begin
                        counter_TX <= 0;
                        if (index < 7) begin
                            index <= index + 1;         // Move to the next bit
                        end
                        else if (index == 7) begin
                            index <= 0;                 // Reset index after all 8 bits have been transferred
                            state <= stop;              // Switching to stop state
                        end
                    end
                end
                
            stop:                                       // Trans stop bit
                begin
//                    if (counter_TX < CLKS_PER_BIT) begin
                    if (counter_TX < 8'd87) begin
                        data_out <= 1'b1;
                        counter_TX <= counter_TX + 1;
                    end
                    else 
                        if (counter_TX == 8'd87) begin
//                        if (counter_TX < CLKS_PER_BIT) begin
                        counter_TX <= 0;
                        trans_active_reg <= 0;
                        done_reg <= 1;
                        state <= done;
                    end
                end
                    
            done:
                begin
                    trans_active_reg <= 0;
                    state <= waiting;  
                end       
                
            default: state <= waiting;
                
        endcase                   
    end
    
   
    assign trans_active = trans_active_reg;
    assign done_sig = done_reg;
    
endmodule
