module uart_receiver(
    input wire clk,
    input wire rst,
    input wire serial_in,
    output reg [7:0] data_out,
    output reg byte_ready
);

    localparam IDLE = 2'b00,
               START_BIT = 2'b01,
               RECEIVE = 2'b10,
               STOP_BIT = 2'b11;

    reg [1:0] state = IDLE;
    reg [3:0] bit_cnt = 0;
    reg [7:0] shift_reg = 0;
    reg [5:0] baud_counter = 0; // Counter for sampling points, sized to count up to 16

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            bit_cnt <= 0;
            shift_reg <= 0;
            baud_counter <= 0;
            byte_ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (serial_in == 0) begin  // Detect start bit
                        baud_counter <= 0;    // Reset baud counter on start bit detection
                        state <= START_BIT;
                    end
                end
                START_BIT: begin
                    baud_counter <= baud_counter + 1;
                    if (baud_counter == 8) begin  // Sample start bit after 8 cycles
                        if (serial_in == 0) begin  // Confirm start bit is still low
                            state <= RECEIVE;
                            bit_cnt <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
                RECEIVE: begin
                    baud_counter <= baud_counter + 1;
                    if (baud_counter == 16) begin  // Sample at mid-point of each bit period
                        shift_reg[bit_cnt] <= serial_in;
                        bit_cnt <= bit_cnt + 1;
                        baud_counter <= 0;  // Reset baud counter after sampling
                        if (bit_cnt == 8) begin
                            state <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    baud_counter <= baud_counter + 1;
                    if (baud_counter == 16) begin  // Sample stop bit at mid-point
                        if (serial_in == 1) begin  // Confirm stop bit is high
                            data_out <= shift_reg;
                            byte_ready <= 1;
                            state <= IDLE;
                        end else begin
                            state <= IDLE;  // Error in stop bit, return to IDLE
                        end
                    end
                end
            endcase
        end
    end

endmodule
