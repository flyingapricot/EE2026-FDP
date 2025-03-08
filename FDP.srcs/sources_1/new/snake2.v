`timescale 1ns / 1ps

module snake2(
    input clock_45Hz, 
    input clock_25MHz, 
    input [6:0] x,
    input [6:0] y, 
    input reset,
    input prev,
    output reg [15:0] oled_data,
    output reg is_done = 0
);

    reg [6:0] box2_xmin = 85;
    reg start;
    
    always @ (posedge clock_45Hz or posedge reset) begin
        if (reset) begin
            box2_xmin <= 85;
            is_done <= 0;
        end
        else if (start) begin
            if (box2_xmin > 43) begin 
                is_done <= 0;
                box2_xmin <= box2_xmin - 1; 
            end else begin
                is_done <= 1;
                box2_xmin <= 85;
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
        if ((x >= box2_xmin && x <= 85) && (y >= 53 && y <= 63) ||
            (x >= 85 && x <= 95) && (y >= 0 && y <= 63)) begin
            oled_data <= 16'b11111_101100_00000; // orange
        end else begin
            oled_data <= 16'd0;
        end
    end
    
endmodule
