`timescale 1ns / 1ps

module sensor_fsm (
    input  wire        clk,          // 100MHz System Clock
    input  wire        rst_n,        // Active-low Reset
    output reg  [1:0]  state,        // Current State Monitoring
    output reg         sample_start, // Trigger ADC Sampling
    output reg         fifo_wr_en    // Write Enable to FIFO
);

    // FSM States Definition
    localparam STATE_IDLE   = 2'b00;
    localparam STATE_SAMPLE = 2'b01;
    localparam STATE_SEND   = 2'b10;

    reg [1:0] next_state;
    reg [15:0] tick_counter;
    wire       tick_pulse;

    // 100MHz 기준 Tick 생성 (예: 1000 클럭 주기마다 펄스 생성 -> 100kHz)
    assign tick_pulse = (tick_counter == 16'd999);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_counter <= 16'd0;
        end else if (tick_pulse) begin
            tick_counter <= 16'd0;
        end else begin
            tick_counter <= tick_counter + 1'b1;
        end
    end

    // FSM State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next State & Output Logic
    always @(*) begin
        next_state   = state;
        sample_start = 1'b0;
        fifo_wr_en   = 1'b0;

        case (state)
            STATE_IDLE: begin
                if (tick_pulse) begin
                    next_state = STATE_SAMPLE;
                end
            end
            
            STATE_SAMPLE: begin
                sample_start = 1'b1;
                next_state   = STATE_SEND;
            end
            
            STATE_SEND: begin
                fifo_wr_en = 1'b1;
                next_state = STATE_IDLE;
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
