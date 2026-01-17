`timescale 1ns / 1ps

module tb_layer_top();

    logic clk;
    logic rst_n;
    logic start;
    logic signed [15:0] d_in;
    logic [3:0] prediction;
    logic layer_done;

    logic [9:0]  pixel_cnt;
    logic [15:0] image_data [0:783];
    logic [3:0]  labels [0:99];
    logic [3:0]  delay_cnt;
    logic        active_streaming;

    integer i, log_file, score_file;
    string file_name;
    localparam int STARTUP_DELAY = 2; 

    layer_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .d_in(d_in),
        .prediction(prediction),
        .layer_done(layer_done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_cnt <= 0;
            active_streaming <= 0;
            d_in <= 0;
            delay_cnt <= 0;
        end 
        else if (start) begin
            pixel_cnt <= 0;
            delay_cnt <= STARTUP_DELAY;
            active_streaming <= 1;
        end 
        else if (active_streaming) begin
            if (delay_cnt > 0) begin
                delay_cnt <= delay_cnt - 1;
                d_in <= 0;
            end 
            else if (pixel_cnt < 784) begin
                d_in <= image_data[pixel_cnt];
                pixel_cnt <= pixel_cnt + 1;
            end 
            else begin
                active_streaming <= 0;
                d_in <= 0;
            end
        end
    end

    initial begin
        $readmemh("data/labels.mem", labels);
        log_file = $fopen("data/hardware_results.txt", "w");
        score_file = $fopen("data/hardware_scores.txt", "w");
        
        rst_n = 0;
        start = 0;
        #50;
        rst_n = 1;
        #20;

        for (i = 0; i < 100; i = i + 1) begin
            file_name = $sformatf("data/test_images_100/image_%0d.mem", i);
            $readmemh(file_name, image_data);
            
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            wait(layer_done);
            
            $fwrite(log_file, "%0d:%0d\n", i, prediction);
            
            $fwrite(score_file, "%0d:", i);
            for (int n = 0; n < 10; n = n + 1) begin
                $fwrite(score_file, "%0d%s", $signed(dut.neuron_outputs[n]), (n==9) ? "" : ",");
            end
            $fwrite(score_file, "\n");

            #100;
        end

        $fclose(log_file);
        $fclose(score_file);
        $finish;
    end

endmodule