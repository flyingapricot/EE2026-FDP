`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: Mark Neo Qi Hao
//  STUDENT B NAME: Neeraj Kumbar
//  STUDENT C NAME: Isaac Saw
//  STUDENT D NAME: Lee Hao Zhe
//
//////////////////////////////////////////////////////////////////////////////////

module clk_div(input CLOCK, [31:0] m, output reg my_clk = 0);
  
    reg [31:0] count = 0;
    
    always @ (posedge CLOCK)
    begin 
        count <= (count == m) ? 0 : count + 1;
        my_clk <= (count == 0) ? ~my_clk : my_clk;
    end

endmodule

module oled_14(
    input wire clk25m,          // 25 MHz Clock
    input wire [12:0] pixel_index, // Pixel index (0-6143 for 96x64 display)
    output reg [15:0] oled_data    // OLED pixel data (RGB565)
);

    // Extract X and Y coordinates from pixel index
    wire [6:0] x = pixel_index % 96;  // X coordinate (0 to 95)
    wire [5:0] y = pixel_index / 96;  // Y coordinate (0 to 63)

    // Define the bounding box for "1" and "4"
    wire is_digit_1 = (x >= 20 && x < 36) && (y >= 16 && y < 48);
    wire is_digit_4 = (x >= 40 && x < 68) && (y >= 16 && y < 48);

    // Define the pixels for "1"
    wire pixel_1 = is_digit_1 && (x >= 28 && x < 32); // Thin vertical line
    
    // Define the pixels for "4"
    wire pixel_4 = is_digit_4 && (
        (x >= 40 && x < 44 && y >= 16 && y < 36) ||  // Left vertical bar (half height)
        (x >= 56 && x < 60 && y >= 16 && y < 48) ||  // Right vertical bar 
        (y >= 32 && y < 36 && x >= 40 && x < 60)     // Middle horizontal bar
    );

    // Set OLED data output
    always @(posedge clk25m) begin
        oled_data <= (pixel_1 || pixel_4) ? 16'hFFFF : 16'h0000; // White for numbers, black otherwise
    end
    
endmodule

module seven_seg_display(
    input clk,
    output reg [6:0] seg,
    output reg dp,
    output reg [3:0] an
);
    
    // The seven-segments displays must show your group ID in this format: 53.14
    
    // Define the 7-segment encoding for digits 0-9
    parameter [6:0] SEG_0 = 7'b1000000; // 0
    parameter [6:0] SEG_1 = 7'b1111001; // 1
    parameter [6:0] SEG_2 = 7'b0100100; // 2
    parameter [6:0] SEG_3 = 7'b0110000; // 3
    parameter [6:0] SEG_4 = 7'b0011001; // 4
    parameter [6:0] SEG_5 = 7'b0010010; // 5
    parameter [6:0] SEG_6 = 7'b0000010; // 6
    parameter [6:0] SEG_7 = 7'b1111000; // 7
    parameter [6:0] SEG_8 = 7'b0000000; // 8
    parameter [6:0] SEG_9 = 7'b0010000; // 9

    // Define the digits to display
    reg [6:0] digit [0:3];
    initial begin
        digit[0] = SEG_5; // 5
        digit[1] = SEG_3; // 3
        digit[2] = SEG_1; // 1
        digit[3] = SEG_4; // 4
    end
    
    // Counter to cycle through the displays
    reg [1:0] count = 0;
    always @(posedge clk) begin
        case (count)
            2'b00: begin
                an <= 4'b0111; // Activate first display
                seg <= digit[0]; // Display '5'
                dp <= 1'b1; // Turn off decimal point
            end
            2'b01: begin
                an <= 4'b1011; // Activate second display
                seg <= digit[1]; // Display '3'
                dp <= 1'b0; // Turn on decimal point
            end
            2'b10: begin
                an <= 4'b1101; // Activate third display
                seg <= digit[2]; // Display '1'
                dp <= 1'b1; // Turn off decimal point
            end
            2'b11: begin
                an <= 4'b1110; // Activate fourth display
                seg <= digit[3]; // Display '4'
                dp <= 1'b1; // Turn off decimal point
            end
        endcase
        // Increment the counter
        count <= count + 1;
    end
    
endmodule

module selectedFrequency(input clk, 
                         input[2:0] taskSelect,
                         output freq_clk);
                         
    wire clk5Hz;
    wire clk10Hz;
    wire clk1Hz;
    wire clk8Hz;
    
    clk_div Clock_5_Hz(clk, 9_999_999, clk5Hz);
    clk_div Clock_10_Hz(clk, 4_999_999, clk10Hz);      
    clk_div Clock_1_Hz(clk, 49_999_999, clk1Hz);    
    clk_div Clock_8_Hz(clk, 6_249_999, clk8Hz);    
    
    assign freq_clk = (taskSelect == 0) ? clk8Hz :
                      (taskSelect == 1) ? clk10Hz :
                      (taskSelect == 2) ? clk5Hz :
                      (taskSelect == 3) ? clk1Hz : 0;
    
endmodule

//Selects the task based on the swtiches selected
module selectTask(input[15:0] SW,
                  output[2:0] selectSignal
                  );
                      
    //2, 8, 1, 4, 8, 4 (D) (1,2,4,8)
    //2, 7, 2, 6, 8, 9 (B) (2,6,7,8,9)
    //2, 7, 2, 4, 0, 0 (C) (0,2,4,7)
    //2, 7, 1, 7, 3, 7 (A) (1,2,3,7)
    assign selectSignal = (SW == 16'b0000_0000_1000_1110) ? 0 :
                          (SW == 16'b0000_0011_1100_0100) ? 1 :
                          (SW == 16'b0000_0000_1001_0101) ? 2 :
                          (SW == 16'b0000_0001_0001_0110) ? 3 : 4;
endmodule
                  
module Top_Student (input clk,
                    output[7:0] JB,
                    input btnC,
                    input btnL,
                    input btnR,
                    input btnD,
                    input btnU,
                    inout PS2Clk,          // PS/2 clock signal (connected to C17)
                    inout PS2Data,         // PS/2 data signal (connected to B17)
                    input[15:0] sw,
                    output reg [15:0] led,
                    output [6:0] seg,
                    output dp,
                    output [3:0] an
                    );
                   
     
    //Green
    //16'h07E0 = 0000 0111 1110 0000 (binary representation)
    //First 5 bits from left represent red (Max intensity is 31)
    //Next 6 bits represent blue (Max intensity is 63)
    //Next 5 bits represent green (Max intensity is 31)
    
    //Red
    //1111 1000 0000 0000
    
    wire clk6p25m; //6.25MHz Clock
    wire clk25m;   //25MHz Clock
    wire clk1000; //100Hz Clock
    wire clk1khz; // 1 kHz Clock for 7-segment display and for debouncing

    
    clk_div Clock_6_25_MHz(clk, 32'd7, clk6p25m);   // 6.25 MHz
    clk_div Clock_25_MHz(clk, 32'd1, clk25m);       // 25 MHz
    clk_div Clock_1_kHz(clk, 32'd49999, clk1khz);   // 1 kHz (100 MHz / 50000)
    

    // When no individual basic tasks are being demonstrated, two digits (Leading zero must be present 
    // for single digit team numbers) representing your group ID should be shown on the OLED screen. 
    // You can use a set of thick straight lines to write the group ID on the OLED.
    
    // OLED signals
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    wire[15:0] oled_data;
    
    wire[15:0] oled_data_a;
    wire[15:0] oled_data_c;
    wire[15:0] oled_data_d;
    wire[15:0] oled_data_init;
    
    //Task selection
    wire[2:0] taskSelect;
    wire selectedFreq;
    
    reg subtask_reset = 0;  
    reg[2:0] prev_taskSelect = 4;  
    
    selectTask select_task(sw,taskSelect);
    
    selectedFrequency select_frequency(clk,taskSelect,selectedFreq);

    // Instantiate the module to generate pixel data for "14"
    oled_14 display_14 (
        .clk25m(clk25m),                // 25 MHz Clock
        .oled_data(oled_data_init),     // OLED pixel data (RGB565)
        .pixel_index(pixel_index)       // Pixel index input
    );
    
    //Instantiation of subtaskA
    subtaskA SubTaskA(clk25m,
                      clk1khz,
                      oled_data_a, 
                      pixel_index, 
                      btnC, 
                      btnU, 
                      btnD,
                      subtask_reset);

    // Instantiate subtaskC
    basic_task_c part_c (clk6p25m, clk25m, clk, pixel_index, btnC, subtask_reset, oled_data_c);


    // Instantiate square_movement module
    basic_task_D square_movement (  .clk(clk),
                                    .clk25m(clk25m),
                                    .JB(JB),
                                    .PS2Clk(PS2Clk),
                                    .PS2Data(PS2Data),
                                    .btnC(btnC), 
                                    .btnR(btnR),
                                    .btnL(btnL),
                                    .btnU(btnU),
                                    .btnD(btnD),
                                    .pixel_index(pixel_index),
                                    .oled_data(oled_data_d)
                                  );

    assign oled_data = (taskSelect == 0) ? oled_data_a : 
                       (taskSelect == 2) ? oled_data_c :
                       (taskSelect == 3) ? oled_data_d : 
                       oled_data_init;
                       

    always @(posedge clk) begin
        if (taskSelect != prev_taskSelect) begin
            subtask_reset <= 1; // Reset when switching tasks
            prev_taskSelect <= taskSelect;
        end else begin
            subtask_reset <= 0; // Stop resetting after 1 cycle
        end
    end


    
    // Instantiation of the oled display
    Oled_Display oled (
        .clk(clk6p25m),                 // Clock input
        .reset(0),                      // Reset signal (if applicable)
        .frame_begin(frame_begin),      // Frame begin signal
        .sending_pixels(sending_pixels),// Sending pixels flag
        .sample_pixel(sample_pixel),    // Sample signal input
        .pixel_index(pixel_index),      // Pixel index input
        .pixel_data(oled_data),         // OLED data input
        .cs(JB[0]),                     // Chip select
        .sdin(JB[1]),                   // Serial data input
        .sclk(JB[3]),                   // Serial clock
        .d_cn(JB[4]),                   // Data/command select
        .resn(JB[5]),                   // Reset
        .vccen(JB[6]),                  // Power control
        .pmoden(JB[7])                  // Ground
    );

    // The seven-segments displays must show your group ID in this format: 53.14
    seven_seg_display ssd (
        .clk(clk1khz),                  // 1 kHz Clock for 7-segment display
        .seg(seg),                      // Segment outputs
        .dp(dp),                        // Decimal point
        .an(an)                         // Anode outputs
    );
    
    
    integer i;
    
    always @(*) begin
        led = sw;
        if(taskSelect == 0) begin
            //All LEDs corresponding to 0 should blink at the selectedFrequency
            led[1] = selectedFreq;
            led[2] = selectedFreq;
            led[3] = selectedFreq;
            led[7] = selectedFreq;
        end
        else if(taskSelect == 1) begin
            //All LEDs corresponding to 0 should blink at the selectedFrequency
            led[2] = selectedFreq;
            led[6] = selectedFreq;
            led[7] = selectedFreq;
            led[8] = selectedFreq;
            led[9] = selectedFreq;
        end
        else if(taskSelect == 2) begin
            //All LEDs corresponding to 0 should blink at the selectedFrequency
            led[0] = selectedFreq;
            led[2] = selectedFreq;
            led[4] = selectedFreq;
            led[7] = selectedFreq;
        end
        else if(taskSelect == 3) begin
            //All LEDs corresponding to 0 should blink at the selectedFrequency
            led[1] = selectedFreq;
            led[2] = selectedFreq;
            led[4] = selectedFreq;
            led[8] = selectedFreq;
        end
    end
    


endmodule

module subtaskA(input clk25m,
                input clk1000,
                input [15:0] oled_data,
                input[12:0] pixelIndex,
                input CENTER_BTN,
                input UP_BTN,
                input DOWN_BTN,
                input subtask_reset);

    wire[6:0] x;
    wire[5:0] y;
    reg resetVal;
        
    assign x = pixelIndex % 96;
    assign y = pixelIndex / 96;
    
    reg[15:0] OLED_DATA;
    assign oled_data = OLED_DATA;
    
    reg [12:0] pixel_index;
    assign pixelIndex = pixel_index;
    
    reg[15:0] RED_COLOUR = 16'b11111_000000_00000;
    reg[15:0] GREEN_COLOUR = 16'b00000_111111_00000;

        
    reg circlePresentFlag = 0;
    reg startCircle = 0;
    reg[5:0] innerDiameter = 25;
    reg[5:0] outerDiameter = 30;
    reg [7:0] debounce_counter = 0;
    reg startTimer = 0;
    reg count = 0;
    reg buttonPress = 0;
    
    reg center_prev = 0;
    reg up_prev = 0;
    reg down_prev = 0;
    reg debounce_on = 0;
    
    reg center_pressed = 0;
    reg up_pressed = 0;
    reg down_pressed = 0;
    
    //Button debouncing with edge detection
    always @(posedge clk1000 or posedge subtask_reset) begin
        if(subtask_reset == 1) begin
            startCircle <= 0;
            circlePresentFlag <= 0;
            innerDiameter <= 25;
            outerDiameter <= 30;
        end
        else begin
            //First compare the prev state and current state and see if there is a change
            if(center_prev == 0 && CENTER_BTN == 1 && debounce_on == 0) begin
                debounce_on <= 1;
                center_pressed <= 1;
            end
            if(up_prev == 0 && UP_BTN == 1 && debounce_on == 0) begin
                debounce_on <= 1;
                up_pressed <= 1;
            end
            if(down_prev == 0 && DOWN_BTN == 1 && debounce_on == 0) begin
                debounce_on <= 1;
                down_pressed <= 1;
            end
            
            //Update the prev states
            center_prev <= CENTER_BTN;
            up_prev <= UP_BTN;
            down_prev <= DOWN_BTN;
            
           //Debounce timer: For 200ms, ignore any other button presses
           if (debounce_on == 1) begin
            debounce_counter <= debounce_counter + 1;
            if (debounce_counter >= 200) begin
                debounce_on <= 0;
                debounce_counter <= 0;
            end
           end
           
           //Perform the button that was pressed
           if (center_pressed == 1) begin
            startCircle <= 1;
            center_pressed <= 0;
           end
           if (down_pressed == 1 && outerDiameter > 10) begin
            outerDiameter <= outerDiameter - 5;
            innerDiameter <= innerDiameter - 5;
            down_pressed <= 0;
           end
           if (up_pressed == 1 && outerDiameter < 50) begin
            outerDiameter <= outerDiameter + 5;
            innerDiameter <= innerDiameter + 5;
            up_pressed <= 0;
           end
       end
    end
    
    
    //Update OLED
    always @(posedge clk25m) begin
    
        if (subtask_reset == 1) begin
            OLED_DATA <= 16'b00000_000000_00000;
        end
        else begin
            //Assign the each pixel of framebuffer to the current pixelIndex
            if(x >= 0 && x <= 93 && y >= 2 && y <= 5) begin
                //Top Border
                OLED_DATA = RED_COLOUR;
            end
            
            else if(x >= 0 && x <= 93 && y >= 59 && y <= 61) begin
                //Bottom Border
                OLED_DATA = RED_COLOUR;
            end
            
            else if(x >= 0 && x <= 3 && y >= 2 && y <= 61) begin
                //Left Border
                OLED_DATA = RED_COLOUR;
            end
            
            else if(x >= 90 && x <= 93 && y >= 2 && y <= 61) begin
                //Right Border
                OLED_DATA = RED_COLOUR;
            end
            
            else if (startCircle == 1 && circlePresentFlag == 0) begin
                //initalise the display
                            
                 if ( ((x - 47) * (x - 47)) + ((y - 32) * (y - 32)) <= ( (innerDiameter/2) * (innerDiameter/2) )) begin
                     OLED_DATA = 16'b00000_000000_00000;
                 end
                 else if ( ((x - 47) * (x - 47)) + ((y - 32) * (y - 32)) >= ( (innerDiameter/2) * (innerDiameter/2) ) && 
                           ((x - 47) * (x - 47)) + ((y - 32) * (y - 32)) <= ( (outerDiameter/2) * (outerDiameter/2) ) ) begin
                     OLED_DATA = GREEN_COLOUR;
                 end
                 
                 else begin
                     OLED_DATA = 16'b00000_000000_00000;
                 end
                 
                 circlePresentFlag <= 1;
                 
            end
            
            else if(circlePresentFlag == 1) begin
                
                if ( ((x - 47) * (x - 47)) + ((y - 32) * (y - 32)) <= ( (innerDiameter/2) * (innerDiameter/2) )) begin
                    OLED_DATA = 16'b00000_000000_00000;
                end
                
                else if ( ((x - 47) * (x - 47)) + ((y - 32) * (y - 32)) >= ( (innerDiameter/2) * (innerDiameter/2) ) && 
                          ((x - 47) * (x - 47)) + ((y - 32) * (y - 32)) <= ( (outerDiameter/2) * (outerDiameter/2) ) ) begin
                    OLED_DATA = GREEN_COLOUR;
                end
                
                else begin
                    OLED_DATA = 16'b00000_000000_00000;
                end
            end
            
            else begin
                OLED_DATA = 16'b00000_000000_00000;
            end
        end
        
    end
    
endmodule


module basic_task_D(
    input clk,             // 100 MHz input clock (Basys 3)
    input clk25m,
    output [7:0] JB,       // Pmod Header for OLED
    inout PS2Clk,          // PS/2 clock signal (connected to C17)
    inout PS2Data,         // PS/2 data signal (connected to B17)
    input btnC,            // Reset Button
    input btnR,            // Right button
    input btnL,            // Left button
    input btnU,            // Up button
    input btnD,             // Down button
    input[12:0] pixel_index,
    output reg[15:0] oled_data
);
    

    // Parameters for screen and square sizes
    localparam SCREEN_WIDTH = 96;
    localparam SCREEN_HEIGHT = 64;
    localparam GREEN_SQUARE_SIZE = 10;
    localparam RED_SQUARE_SIZE = 30;
    localparam MOVEMENT_SPEED = 30; // pixels per second
    
    // Extract X and Y coordinates from pixel index
    reg [6:0] x;
    reg [5:0] y;
    
    always @(*) begin
        x = pixel_index % 96;  // X coordinate (0 to 95)
        y = pixel_index / 96;  // Y coordinate (0 to 63)
    end
    
    // Positions for the squares
    reg [6:0] green_x = 0;
    reg [5:0] green_y = SCREEN_HEIGHT - GREEN_SQUARE_SIZE;
    reg [6:0] red_x = SCREEN_WIDTH - RED_SQUARE_SIZE;
    reg [5:0] red_y = 0;

    // Movement direction
    reg [2:0] direction = 0; // 0: stop, 1: right, 2: left, 3: up, 4: down

    // Clock divider for movement speed
    reg [31:0] counter = 0;
    localparam CLK_DIV = 100000000 / MOVEMENT_SPEED;
    
    // Button edge detection
    reg btnR_last, btnL_last, btnU_last, btnD_last;

    always @(posedge clk or posedge btnC) begin
        if (btnC) begin
            green_x <= 0;
            green_y <= SCREEN_HEIGHT - GREEN_SQUARE_SIZE;
            direction <= 0;
            counter <= 0;
        end else begin
            // Edge detection for buttons
            btnR_last <= btnR;
            btnL_last <= btnL;
            btnU_last <= btnU;
            btnD_last <= btnD;
        
            if (btnR && !btnR_last) direction <= 1;
            else if (btnL && !btnL_last) direction <= 2;
            else if (btnU && !btnU_last) direction <= 3;
            else if (btnD && !btnD_last) direction <= 4;

            // Movement logic
            if (counter >= CLK_DIV) begin
                counter <= 0;
                case (direction)
                    1: if (green_x + GREEN_SQUARE_SIZE < SCREEN_WIDTH &&
                           !(green_x + GREEN_SQUARE_SIZE >= red_x && green_x < red_x + RED_SQUARE_SIZE &&
                             green_y + GREEN_SQUARE_SIZE > red_y && green_y < red_y + RED_SQUARE_SIZE)) 
                           green_x <= green_x + 1;
                    2: if (green_x > 0 &&
                           !(green_x <= red_x + RED_SQUARE_SIZE && green_x > red_x &&
                             green_y + GREEN_SQUARE_SIZE > red_y && green_y < red_y + RED_SQUARE_SIZE))
                           green_x <= green_x - 1;
                    3: if (green_y > 0 &&
                           !(green_y <= red_y + RED_SQUARE_SIZE && green_y > red_y &&
                             green_x + GREEN_SQUARE_SIZE > red_x && green_x < red_x + RED_SQUARE_SIZE))
                           green_y <= green_y - 1;
                    4: if (green_y + GREEN_SQUARE_SIZE < SCREEN_HEIGHT &&
                           !(green_y + GREEN_SQUARE_SIZE >= red_y && green_y < red_y + RED_SQUARE_SIZE &&
                             green_x + GREEN_SQUARE_SIZE > red_x && green_x < red_x + RED_SQUARE_SIZE))
                           green_y <= green_y + 1;
                endcase
            end else begin
                counter <= counter + 1;
            end
        end
    end
    
        
    
    // Pixel data logic
    always @(posedge clk25m) begin
        if (x >= green_x && x < green_x + GREEN_SQUARE_SIZE && y >= green_y && y < green_y + GREEN_SQUARE_SIZE)
            oled_data <= 16'h07E0; // Green (RGB565)
        else if (x >= red_x && x < red_x + RED_SQUARE_SIZE && y >= red_y && y < red_y + RED_SQUARE_SIZE)
            oled_data <= 16'hF800; // Red (RGB565)
        else
            oled_data <= 16'h0000; // Black (RGB565)
    end
    
endmodule
