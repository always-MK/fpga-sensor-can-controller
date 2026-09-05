`timescale 1ns / 1ps

module tb_sensor_fsm;

    reg  clk;
    reg  rst_n;
    wire [1:0] state;
    wire sample_start;
    wire fifo_wr_en;

    // DUT 인스턴스화
    sensor_fsm uut (
        .clk(clk),
        .rst_n(rst_n),
        .state(state),
        .sample_start(sample_start),
        .fifo_wr_en(fifo_wr_en)
    );

    // 100MHz 클럭 생성 (주기 10ns)
    initial clk = 0;
    always #5 clk = ~clk;

    // 리셋 및 시뮬레이션 제어
    initial begin
        rst_n = 0;
        #50;
        rst_n = 1;
        
        // 20000ns(20us) 동안 동작 확인
        #20000;
        $finish;
    end

endmodule
