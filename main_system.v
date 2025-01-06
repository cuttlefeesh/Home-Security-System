// PIR Sensor Module
module pir(
    input wire clk,
    input wire reset,
    input wire motion_detected_in,
    input wire push_button,
    output reg motion_detected,
    output reg [1:0] state
);
    // State encoding
    localparam OFF = 2'b00,
               IDLE = 2'b01,
               MOTION_DETECTED = 2'b10,
               INTERRUPT = 2'b11;

    reg [5:0] countdown;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= OFF;
            motion_detected <= 1'b0;
            countdown <= 6'd0;
        end else begin
            case (state)
                OFF: begin
                    if (!reset) state <= IDLE;
                end

                IDLE: begin
                    if (motion_detected_in) begin
                        state <= MOTION_DETECTED;
                        motion_detected <= 1'b1;
                    end
                end

                MOTION_DETECTED: begin
                    if (push_button) begin
                        state <= INTERRUPT;
                        motion_detected <= 1'b0;
                        countdown <= 6'd60; // 1-minute countdown
                    end
                end

                INTERRUPT: begin
                    if (countdown > 0)
                        countdown <= countdown - 1;
                    else
                        state <= IDLE;
                end
            endcase
        end
    end
endmodule

// Buzzer Module
module buzzer(
    input wire motion_detected,
    output reg buzzer_signal
);
    always @(*) begin
        buzzer_signal = motion_detected;
    end
endmodule

// LED RGB Module
module led_rgb(
    input wire [1:0] state,
    output reg [2:0] led_color // RGB encoding: Green = 3'b010, Red = 3'b100, Blue = 3'b001
);
    always @(*) begin
        case (state)
            2'b00: led_color = 3'b000; // OFF
            2'b01: led_color = 3'b010; // Green (IDLE)
            2'b10: led_color = 3'b100; // Red (MOTION_DETECTED)
            2'b11: led_color = 3'b001; // Blue (INTERRUPT)
            default: led_color = 3'b000;
        endcase
    end
endmodule

// RTC Module
module rtc(
    input wire clk,
    input wire reset,
    output reg [31:0] time_data, // Placeholder for time representation
    output reg [5:0] countdown
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            time_data <= 32'd0;
            countdown <= 6'd0;
        end else begin
            time_data <= time_data + 1; // Increment time for simulation
        end
    end
endmodule

// LCD Module
module lcd(
    input wire [1:0] state,
    input wire [31:0] time_data,
    input wire [5:0] countdown,
    output reg [127:0] display_text // Placeholder for LCD text
);
    always @(*) begin
        case (state)
            2'b00: display_text = "System OFF";
            2'b01: display_text = {"Sensor aktif: ", time_data};
            2'b10: display_text = "Gerakan Terdeteksi";
            2'b11: display_text = {"Countdown: ", countdown};
            default: display_text = "Unknown State";
        endcase
    end
endmodule

// Top-level Module
module main_system(
    input wire clk,
    input wire reset,
    input wire motion_detected_in,
    input wire push_button,
    output wire buzzer_signal,
    output wire [2:0] led_color,
    output wire [127:0] display_text
);
    wire [1:0] state;
    wire motion_detected;
    wire [31:0] time_data;
    wire [5:0] countdown;

    pir pir_inst(
        .clk(clk),
        .reset(reset),
        .motion_detected_in(motion_detected_in),
        .push_button(push_button),
        .motion_detected(motion_detected),
        .state(state)
    );

    buzzer buzzer_inst(
        .motion_detected(motion_detected),
        .buzzer_signal(buzzer_signal)
    );

    led_rgb led_rgb_inst(
        .state(state),
        .led_color(led_color)
    );

    rtc rtc_inst(
        .clk(clk),
        .reset(reset),
        .time_data(time_data),
        .countdown(countdown)
    );

    lcd lcd_inst(
        .state(state),
        .time_data(time_data),
        .countdown(countdown),
        .display_text(display_text)
    );
endmodule
