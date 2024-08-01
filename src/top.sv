module uart_system_top(
    input wire clk,           // System clock
    input wire rst,           // System reset
    input wire serial_in,     // Serial input from UART transmitter
    output wire [7:0] data_out,  // Output data byte received from UART
    output wire byte_ready,   // Flag to indicate a byte has been received
    input wire [31:0] dvsr    // Baud rate divisor (set based on clock and desired baud rate)
);

    // Signals for UART and Baud Rate Generator
    logic tick;           // Tick from baud rate generator

    reg [31:0] counter = 0;   // Counter to divide the clock

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            tick <= 0;
        end else begin
            if (counter >= (dvsr - 1)) begin
                counter <= 0;   // Reset counter
                tick <= 1;      // Generate a tick
            end else begin
                counter <= counter + 1;
                tick <= 0;
            end
        end
    end

    // Instance of UART receiver
    uart_receiver uart_rx(
        .clk(tick),       // Clock driven by baud rate tick
        .rst(rst),
        .serial_in(serial_in),
        .data_out(data_out),
        .byte_ready(byte_ready)
    );

endmodule
