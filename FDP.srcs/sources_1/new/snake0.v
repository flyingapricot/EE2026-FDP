`timescale 1ns / 1ps

module snake0(input clock_45Hz, 
    input clock_25MHz, 
    input [6:0]x,
    input [6:0] y, 
    output reg [15:0] oled_data
);
    
    always @ (posedge clock_25MHz) begin
        if ((x >= 85 && x <= 95) && (y >= 0 && y <= 10)) begin
            oled_data <= 16'b11111_101100_00000;
        end else begin
            oled_data <= 16'd0;
        end
    end
    
endmodule
