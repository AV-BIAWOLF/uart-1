module uart_tx_tb;

    // Параметр для тактового сигнала на бит
    parameter CLKS_PER_BIT = 87;

    // Сигналы тестбенча
    reg clk = 0;
    reg data_ready = 0;
    reg [7:0] byte_trans;
    wire trans_active;
    wire data_out;
    wire done_sig;

    // Генерация тактового сигнала
    always #1 clk = ~clk; // Период тактового сигнала 10 единиц времени

    // Инстанцирование тестируемого модуля
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut (
        .clk(clk),
        .data_ready(data_ready),
        .byte_trans(byte_trans),
        .trans_active(trans_active),
        .data_out(data_out),
        .done_sig(done_sig)
    );

    initial begin
        // Инициализация входных сигналов
        byte_trans = 8'b10101010; // Передаем байт с данными
        data_ready = 0;
        #87;

        // Тест 1: Передача данных
        data_ready = 1; // Данные готовы для передачи
        #87;
        data_ready = 0; // Снимаем сигнал готовности

        // Ждем завершения передачи
        
        #10;

        // Тест завершен
        $stop;
    end

endmodule
