`timescale 1ns / 1ps

module snake6(
    input clock_15Hz, 
    input clock_25MHz, 
    input [6:0] x,
    input [6:0] y,
    input reset,
    input prev,
    output reg [15:0] oled_data,
    output reg is_done
);

    reg [6:0] box6_xmax = 69;
    reg start;
    
    always @ (posedge clock_15Hz) begin
        if (reset) begin
            box6_xmax <= 69;
            is_done <= 0;
        end
        else if (start) begin
            if (box6_xmax < 85) begin
                is_done <= 0;
                box6_xmax <= box6_xmax + 1; 
            end else begin
                is_done <= 1;
                box6_xmax <= 69;
            end
        end else begin
            is_done <= 0;
        end
    end
    
    always @ (posedge clock_25MHz) begin
        if (is_done || reset) begin
            start <= 0;
        end
        if (prev) begin
            start <= 1;
        end
        if ((x >= 69 && x <= box6_xmax) && (y >= 0 && y <= 10) ||
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
    
endmodule
