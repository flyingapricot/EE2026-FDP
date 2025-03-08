`timescale 1ns / 1ps

// should turn on full pattern if prev is HIGH
module snake7( 
    input clock_25MHz, 
    input [6:0] x,
    input [6:0] y,
    input prev,
    input reset7,
    output reg [15:0] oled_data
);
    
    reg is_on;
    
    always @ (posedge clock_25MHz) begin
        if (prev) is_on <= 1;
        if (reset7) is_on <= 0;
        if (is_on) begin
            if ((x >= 69 && x <= 85) && (y >= 0 && y <= 10) ||
                (x >= 59 && x <= 69) && (y >= 0 && y <= 37) ||
                (x >= 43 && x <= 69) && (y >= 27 && y <= 37) ||
                (x >= 43 && x <= 53) && (y >= 27 && y <= 53) ||
                (x >= 43 && x <= 85) && (y >= 53 && y <= 63) ||
                (x >= 85 && x <= 95) && (y >= 0 && y <= 63)) begin
                oled_data <= 16'b11111_101100_00000; // orange
            end else begin
                oled_data <= 16'd0;
            end
        end
    end
    
endmodule
