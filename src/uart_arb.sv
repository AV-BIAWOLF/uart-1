`timescale 1ns / 1ps

module uart_arb
//    #(parameter CLKS_PER_BIT = 87)
//    #(parameter CLKS_PER_BIT = 868)
    #(parameter CLKS_PER_BIT = 217)
    (
        input clk,               // Тактовый сигнал
        input        data_in_RX,        // Входной сигнал данных от RX
//        output [0:7] byte_trans_TX        // Выходной сигнал данных для TX
        output data_out_TX        // Выходной сигнал данных для TX
        
        ,output logic led_1 = 0
        ,output logic led_2 = 0
    );

    // Регистры состояния и другие внутренние сигналы
    logic [7:0] byte_recv_RX;
    logic [7:0] byte_trans_TX;
    logic       trans_active_TX;
    logic       data_ready_TX;
    logic [3:0] count = 0;

    // Инстанцируем модули RX и TX
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
        .clk(clk),
        .data_in(data_in_RX),
        .byte_recv(byte_recv_RX),
        .recv_valid(recv_valid_RX)
    );

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
        .clk(clk),
        .data_ready(data_ready_TX),
        .byte_trans(byte_trans_TX),
        .trans_active(trans_active_TX),
        .data_out(data_out_TX),  // TX передает данные через этот выход
        .done_sig(done_sig_TX)
    );
    
    
    // DEBUG ILA
    ila_0 debugger (
        .clk(clk),

        
        .probe0(byte_recv_RX),
        .probe1(recv_valid_RX),
        .probe2(byte_trans_TX),
        .probe3(data_ready_TX),
        .probe4(trans_active_TX),
        .probe5(done_sig_TX),
        .probe6(led_1),
        .probe7(led_2)
    );
    

    enum reg [4:0] {
        WAITING = 5'b00001,
        RX_O    = 5'b00010,
        RX_K    = 5'b00100,
        TX_MES  = 5'b01000,
        DONE    = 5'b10000
    } state;


    always @(posedge clk) begin
        case(state)
            WAITING: 
                begin
                    data_ready_TX <= 1'b1;
                    
                    if (trans_active_TX == 1'b0) begin
                        case (count)
                            4'd0: begin
                                byte_trans_TX <= 8'h48;  // ASCII для 'H'
                                data_ready_TX <= 1'b1;
                                if (done_sig_TX == 1'b1) begin
                                    data_ready_TX <= 1'b0; // Отключаем передачу
                                    count <= count + 1;    // Переходим к следующему символу
                                    
                                    led_1 <= 1'b1;
                                    
                                end
                            end
            
                            4'd1: begin
                                byte_trans_TX <= 8'h49;  // ASCII для 'I'
                                data_ready_TX <= 1'b1;
                                if (done_sig_TX == 1'b1) begin
                                    data_ready_TX <= 1'b0; // Отключаем передачу
                                    count <= count + 1;
                                
                                    led_2 <= 1'b1;
                                
                                end
                            end
                            
                            4'd2: begin
                                count <= 1'b0;
                                state <= DONE;
                            end
                            
                            
                        endcase                     

                end
                end
            
            DONE:
                begin
                     state <= WAITING;
                end
             
            default: state <= WAITING; 
               
        endcase             
        
    end

endmodule
