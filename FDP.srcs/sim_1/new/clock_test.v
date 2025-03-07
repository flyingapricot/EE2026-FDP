`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2025 14:24:18
// Design Name: 
// Module Name: clock_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




module clock_test();
  reg sim_clock;
  reg [31:0] sim_m;
  wire sim_slow_slow;
  
  flexible_clock_module test_unit_x (.basys_clock(sim_clock), .m(sim_m), .clock_6p25(sim_slow_slow));
  initial begin
      sim_clock = 0;
      sim_m = 32'd7;
  end
  
  always
  begin
  #5; sim_clock = ~sim_clock;    
  end
  endmodule

/*    reg clk_in;     // Simulated 100 MHz clock
    wire clk_out;   // Output 6.25 MHz clock
    //assign clk_out = 0;
    reg out;

    // Instantiate the clock divider module
    clk_6_25_MHz uut (
        .CLOCK(clk_in),
        .SLOW_CLOCK(clk_out)
    );

    // Generate 100 MHz clock (Period = 10ns)
    always #5 clk_in = ~clk_in; // Toggle every 5 ns -> 10 ns period -> 100 MHz

    initial begin
        // Initialize signals
        clk_in = 0;
        assign out = clk_out;
        #20;    // Wait 20 ns
        // Run simulation for 1000 ns (1 µs)
        #1000;
        $stop;  // End simulation
    end

endmodule*/
