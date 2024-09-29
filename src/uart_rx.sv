`timescale 1ns / 1ps

module uart_rx
    #(parameter CLKS_PER_BIT=868)
    (
        input clk,
        input data_in,
        output [7:0] byte_recv,
        output recv_valid
    );
    
    reg data_in_reg_1;
    reg data_in_reg_2;
    reg [7:0] byte_recv_reg;
    reg recv_valid_reg;
    
    // The data in UART are recieved asyncho. It does not work wirh clock signal. 
    // Metastability can be happen. To fix it we should add synch by double-register
    always @(posedge clk) begin
        data_in_reg_1 <= data_in;
        data_in_reg_2 <= data_in_reg_1;
    end
    
    
    enum reg [2:0]{
        waiting = 3'b001,
        start   = 3'b010,
        recive  = 3'b011,
        stop    = 3'b100,
        done    = 3'b101
    }state;
    
    reg [9:0] counter = 0;
    reg [7:0] counter_numbers = 0;
    reg [2:0] index = 0;
    reg       recv_valid_reg = 0;
    reg [7:0] byte_recv_reg = 0;
    reg       done_reg = 0;
    
    logic nul_num;
    logic [3:0] count_W;
    
    always @(posedge clk) begin
        
        case(state)
            waiting:    // Receiving data
                begin
                    recv_valid_reg <= 0;
                    nul_num <= 0;
                    if (data_in_reg_2 == 0)     state <= start;
                end
                
            start:
               begin
                    counter <= counter + 1;
                    // Fix the value at the middle of the period
                    if (counter == (CLKS_PER_BIT - 1) / 2) begin   
                        nul_num <= data_in_reg_2;  // Save the value of data_in_reg_2
                    end
                    // At the end of the full period we check the value
                    if (counter == (CLKS_PER_BIT - 1)) begin     
                        if (nul_num == 1'b0) begin
                            counter <= 0; // Resetting the counter
                            state   <= recive; // Moving to the next state
                        end else begin
                            state <= waiting; // If not 0, we go back to waiting
                        end
                    end
                end
    
            recive:
                begin
                    if (counter < CLKS_PER_BIT) begin   
                            counter <= counter + 1;
                            state <= recive; 
                        end
                    else begin 
                        counter <= 0;
                        byte_recv_reg[index] <= data_in_reg_2;
                        if (index < 7) begin  
                            index <= index + 1;
                            state <= recive;
                        end
                        else begin 
                            index <= 0;
                            state <= stop;
                        end
                    end
                end
                
            stop:
                begin
                    // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                    if (counter < CLKS_PER_BIT) begin // -1
                        counter <= counter + 1;
                    end else begin
                        if (data_in_reg_2 == 1) begin   // Checking that the stop bit (1) has completed
                            recv_valid_reg <= 1;        // Data correctly accepted
                            counter <= 0;               // Resetting the counter
                            state <= done;              // Moving towards completion
                        end else begin
                            counter <= 0;               // If the stop bit is incorrect, reset the counter
                            state <= waiting;           // Back to waiting
                        end
                    end
                end

                
            done: 
                begin
                    recv_valid_reg <= 0; 
                    state <= waiting;  
                    byte_recv_reg <= 0;
                end              
                  
            default: state <= waiting;       
                                            
        endcase
    end
    
    assign byte_recv = byte_recv_reg;
    assign recv_valid = recv_valid_reg;
    
endmodule
