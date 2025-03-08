`timescale 1ns / 1ps

module snake1(input clock_45Hz, 
    input clock_25MHz, 
    input [6:0] x,
    input [6:0] y, 
    input reset,
    input start,
    output reg [15:0] oled_data,
    output reg is_done = 0
);

    reg [6:0] box1_ymax = 10;
    reg moving;
    
    always @ (posedge clock_45Hz or posedge reset) begin
        if (reset) begin
            box1_ymax <= 10;
            is_done <= 0; 
        end else if (moving) begin
            if (box1_ymax < 63) begin
                is_done <= 0; 
                box1_ymax <= box1_ymax + 1; 
            end else begin
                is_done <= 1;
                box1_ymax <= 10;
            end
        end else begin
            is_done <= 0;
        end
    end
    
    always @ (posedge clock_25MHz) begin
        if (is_done || reset) begin
            moving <= 0;
        end
        else if (start) begin
            moving <= 1;
        end
        if ((x >= 85 && x <= 95) && (y >= 0 && y <= box1_ymax)) begin
            oled_data <= 16'b11111_101100_00000;
        end else begin
            oled_data <= 16'd0;
        end
    end
    
endmodule
