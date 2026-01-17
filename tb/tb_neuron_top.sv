module neuron_top_tb();

    logic clk;
    logic rst_n;
    logic start;
    logic signed [15:0] din_x;
    wire signed [39:0] dout;
    wire done;

    logic [15:0] image_data [0:783];

    neuron_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .din_x(din_x),
        .dout(dout),
        .done(done)
    );

initial clk = 0;
always #5 clk = ~clk;

always_ff @(posedge clk) begin
        if (rst_n) begin
            din_x <= image_data[dut.address];
        end
    end

initial begin 
    $readmemh("data/image.mem", image_data);
    rst_n = 0;
    start = 0;
    @(posedge clk); #1;
    rst_n = 1;
    @(posedge clk); #1;

    $display("--- Starting Neuron Inference ---");
    start = 1;
    @(posedge clk);
    start = 0;
    wait(done);

    $display("--- Inference Finished! ---");
    $display("Final Accumulator Value (Hex): %h", dout);
    $display("Final Accumulator Value (Decimal): %f", $itor(dout) / 65536.0); 
    $finish;
end

initial begin
        $dumpfile("neuron_sim.vcd");
        $dumpvars(0, neuron_top_tb);
    end


endmodule