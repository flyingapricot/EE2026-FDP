`timescale 1ns / 1ps

module basic_task_c(
    input clock_6MHz, 
    input clock_25MHz, 
    input basys_clock,
    input [12:0] pixel_index, 
    input btnC,
    input reset, // master reset
    output reg [15:0] oled_data
);
    // 45 and 15 clocks
    reg clock_45Hz = 0;
    reg [31:0] counter_45Hz = 0;
    reg clock_15Hz = 0;
    reg [31:0] counter_15Hz = 0;

    always @(posedge clock_6MHz) begin
        if (counter_45Hz >= 69444) begin
            counter_45Hz <= 0;
            clock_45Hz <= ~clock_45Hz;
        end else counter_45Hz <= counter_45Hz + 1;
        
        if (counter_15Hz >= 208333) begin
            counter_15Hz <= 0;
            clock_15Hz <= ~clock_15Hz;
        end else counter_15Hz <= counter_15Hz + 1;
    end

    // Coordinates calculation
    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    reg [2:0] state = 0;
    reg start = 0;
    
    wire debounced_btnC;
    debouncer db (basys_clock, btnC, debounced_btnC);
    
    wire [15:0] output0;
    snake0 square (clock_45Hz, clock_25MHz, x, y, output0);
    wire is_done1;
    wire [15:0] output1;
    snake1 stage1 (clock_45Hz, clock_25MHz, x, y, reset, start, output1, is_done1);
    wire is_done2;
    wire [15:0] output2;
    snake2 stage2 (clock_45Hz, clock_25MHz, x, y, reset, is_done1, output2, is_done2);
    wire is_done3;
    wire [15:0] output3;
    snake3 stage3 (clock_15Hz, clock_25MHz, x, y, reset, is_done2, output3, is_done3);
    wire is_done4;
    wire [15:0] output4;
    snake4 stage4 (clock_15Hz, clock_25MHz, x, y, reset, is_done3, output4, is_done4);
    wire is_done5;
    wire [15:0] output5;
    snake5 stage5 (clock_15Hz, clock_25MHz, x, y, reset, is_done4, output5, is_done5);
    wire is_done6;
    wire [15:0] output6;
    snake6 stage6 (clock_15Hz, clock_25MHz, x, y, reset, is_done5, output6, is_done6);
    reg reset7;
    wire [15:0] output7;
    snake7 stage7 (clock_25MHz, x, y, is_done6, reset7, output7);
    
    always @ (posedge clock_25MHz) begin
        if (reset) state <= 0;
        case (state)
            0: begin
                oled_data <= output0;
                if (debounced_btnC) begin
                    state <= 1;
                    start <= 1;
                end
            end
            1: begin
                reset7 <= 0; // let snake7 turn on if needed
                oled_data <= output1;
                if (is_done1) begin
                    state <= 2;
                    start <= 0;
                end
            end
            2: begin
                oled_data <= output2;
                if (is_done2) state <= 3;
            end
            3: begin
                oled_data <= output3;
                if (is_done3) state <= 4;
            end
            4: begin
                oled_data <= output4;
                if (is_done4) state <= 5;
            end
            5: begin
                oled_data <= output5;
                if (is_done5) state <= 6;
            end
            6: begin
                oled_data <= output6;
                if (is_done6) state <= 7;
            end
            default: begin
                oled_data <= output7;
                if (debounced_btnC) begin
                    state <= 1;
                    start <= 1;
                    reset7 <= 1;
                end
            end
        endcase
    end
    
endmodule
