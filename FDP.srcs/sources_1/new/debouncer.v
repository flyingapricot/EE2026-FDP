`timescale 1ns / 1ps

module debouncer(
    input clk,          // Clock signal (e.g., clock_25MHz)
    input btn_in,       // Raw button input
    output reg btn_out  // Debounced button output
);

    reg [19:0] count = 0; // 20-bit counter for debouncing
    reg btn_sync = 0;     // Synchronized button signal

    // Synchronize the button input to the clock domain
    always @(posedge clk) begin
        btn_sync <= btn_in;
    end

    // Debounce logic
    always @(posedge clk) begin
        if (btn_sync != btn_out) begin
            if (count == 20'hFFFFF) begin // Wait for a stable signal
                btn_out <= btn_sync;
            end else begin
                count <= count + 1;
            end
        end else begin
            count <= 0; // Reset counter if the button state is stable
        end
    end

endmodule