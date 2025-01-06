// Testbench for main_system module
`timescale 1ns/1ps

module main_system_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg motion_detected_in;
    reg push_button;
    wire buzzer_signal;
    wire [2:0] led_color;
    wire [127:0] display_text;

    // Instantiate the main_system module
    main_system uut (
        .clk(clk),
        .reset(reset),
        .motion_detected_in(motion_detected_in),
        .push_button(push_button),
        .buzzer_signal(buzzer_signal),
        .led_color(led_color),
        .display_text(display_text)
    );

    // Clock generation
    always #1 clk = ~clk; // 100 MHz clock

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        motion_detected_in = 0;
        push_button = 0;

        // Reset system
        #10 reset = 0;

        // Test case 1: System transitions to IDLE
        #10 motion_detected_in = 0; // No motion yet

        // Test case 2: Motion detected
        #20 motion_detected_in = 1; // Simulate motion detection
        #10 motion_detected_in = 0; // Stop motion signal

        // Test case 3: Interrupt via push button
        #30 push_button = 1; // Simulate push button press
        #10 push_button = 0; // Release push button

        // Wait for countdown to complete
        #600;

        // Test case 4: Return to IDLE
        // After countdown, the system should return to IDLE

        // End simulation
        #50 $stop;
    end

    // Monitor output
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, main_system_tb);
        $monitor("Time: %0d | Reset: %b | Motion: %b | Button: %b | State: %h | Buzzer: %b | LED: %b | Display: %s",
                 $time, reset, motion_detected_in, push_button, uut.pir_inst.state, buzzer_signal, led_color, display_text);
    end
endmodule
