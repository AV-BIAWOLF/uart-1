`timescale 1ns / 1ps

module tb_uart_arb();

    // Параметры
    parameter CLKS_PER_BIT = 87;  // 868
    parameter CLK_PERIOD = 10; // Период для тактового сигнала, например, 10ns

    // Входные и выходные сигналы
    logic clk;
    logic data_in_RX;
    logic data_out_TX;
    logic [7:0] data_byte;
    
    logic led_1;
    logic led_2;

    // Подключаем тестируемый модуль
    uart_arb #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_arb_inst (
        .clk(clk),
        .data_in_RX(data_in_RX),
        .data_out_TX(data_out_TX)
        
        ,.led_1(led_1)
        ,.led_2(led_2)
    );

    // Процедура генерации тактового сигнала
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end
    

    // Процедура тестирования
    initial begin

        // Ждем начала симуляции
        #(10 * CLK_PERIOD);
        // Передаем стартовый бит
        
        // Передаем K
        /*data_in_RX = 1'b0;
        #(CLKS_PER_BIT * CLK_PERIOD); 
        // Тест: передаем 'O' (ASCII: 8'h4F)
        data_byte = 8'h4F; // Байт, который нужно отправить (01001111)
        for (int i = 0; i < 8; i = i + 1) begin
            data_in_RX = data_byte[i];
            #(CLKS_PER_BIT * CLK_PERIOD); // Ожидание длительности одного бита
            $display("i = %d   data_byte = %b", i, data_byte[i]);
        end
        data_in_RX = 1'b1;
        $display("\n");
        #(CLKS_PER_BIT * CLK_PERIOD);
        #(CLKS_PER_BIT * CLK_PERIOD);*/
        
        // Передаем O
        /*data_in_RX = 1'b0;
        #(CLKS_PER_BIT * CLK_PERIOD); 
        // Тест: передаем 'K' (ASCII: 8'h4B)
        data_byte = 8'h4B; // Байт, который нужно отправить (01001011)
        for (int i = 0; i < 8; i = i + 1) begin
            data_in_RX = data_byte[i];
            #(CLKS_PER_BIT * CLK_PERIOD); // Ожидание длительности одного бита
            $display("i = %d   data_byte = %b", i, data_byte[i]);
        end
        data_in_RX = 1'b1;
        $display("\n");
        #(CLKS_PER_BIT * CLK_PERIOD);
        #(CLKS_PER_BIT * CLK_PERIOD);
       
        // Передаем \n 
        data_in_RX = 1'b0;
        #(CLKS_PER_BIT * CLK_PERIOD); 
        // Тест: передаем 'K' (ASCII: 8'h4B)
        data_byte = 8'h0D; // Байт, который нужно отправить (01001011)
        for (int i = 0; i < 8; i = i + 1) begin
            data_in_RX = data_byte[i];
            #(CLKS_PER_BIT * CLK_PERIOD); // Ожидание длительности одного бита
            $display("i = %d   data_byte = %b", i, data_byte[i]);
        end
        data_in_RX = 1'b1;
        $display("\n");
        #(CLKS_PER_BIT * CLK_PERIOD);*/
        
        // Окончание симуляции
        #(400 * CLK_PERIOD);
        $finish;
    end

endmodule
