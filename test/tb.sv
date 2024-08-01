`timescale 1ns / 1ps

module uart_system_top_tb;

    // Parameters of the test bench
    localparam SYSTEM_CLOCK_FREQ = 50_000_000;  // 50 MHz system clock
    localparam BAUD_RATE = 1119600;                // Desired baud rate for UART
    localparam DVSR = SYSTEM_CLOCK_FREQ / (16 * BAUD_RATE);  // Baud rate divisor

    // Test bench signals
    reg clk;
    reg rst;
    reg serial_in;
    wire [7:0] data_out;
    wire byte_ready;

    // Instance of the top module
    uart_system_top uut(
        .clk(clk),
        .rst(rst),
        .serial_in(serial_in),
        .data_out(data_out),
        .byte_ready(byte_ready),
        .dvsr(DVSR)
    );

    // Clock generation
    always #10 clk = ~clk;  // Generate a 50 MHz clock (20 ns period)

    // Stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        serial_in = 1;  // Idle state is high

        // Reset the system
        #100 rst = 0;
        #100 rst = 1;

        // Start bit (low)
        serial_in = 0;
        #(DVSR * 16 * 10);  // Wait for one full bit period

        // Send data bits (LSB first)
        // Example byte 0xA5 (10100101 in binary)
        serial_in = 1; #(DVSR * 16 * 10); // Bit 0
        serial_in = 0; #(DVSR * 16 * 10); // Bit 1
        serial_in = 1; #(DVSR * 16 * 10); // Bit 2
        serial_in = 0; #(DVSR * 16 * 10); // Bit 3
        serial_in = 0; #(DVSR * 16 * 10); // Bit 4
        serial_in = 1; #(DVSR * 16 * 10); // Bit 5
        serial_in = 0; #(DVSR * 16 * 10); // Bit 6
        serial_in = 1; #(DVSR * 16 * 10); // Bit 7

        // Stop bit (high)
        serial_in = 1;
        #(DVSR * 16 * 10);  // Wait for one full bit period to complete transmission
       
        // Finish the simulation
        #5000 $finish;
    end
     initial begin
        $dumpfile("Single Cycle.vcd");
        $dumpvars(0);
    end

endmodule
