module baud_rate_gen(
    input wire clk,           // System clock
    input wire rst,           // Reset signal
    input wire [31:0] dvsr,   // Divisor for baud rate generation
    output reg tick           // Output tick signal
);

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

endmodule
