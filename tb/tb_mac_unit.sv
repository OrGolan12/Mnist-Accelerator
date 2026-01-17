module tb_mac_unit();

logic clk;
logic rst_n;
logic signed [15:0] din_x;
logic signed [15:0] din_w;
logic valid_in;
logic clr_acc;
logic signed [39:0] dout;

mac_unit dut(.clk(clk), .rst_n(rst_n), .din_x(din_x),
             .din_w(din_w), .valid_in(valid_in), .clr_acc(clr_acc), .dout(dout));

initial clk = 0;
always #5 clk = ~clk;

initial begin
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk); #1;

    din_x = 16'h0080;
    din_w = 16'h0200;
    valid_in = 1;
    @(posedge clk); #1;
    $display("Test 1: dout = %h (Expected: 0000000100)", dout);

    din_x = 16'h0100;
    din_w = 16'h0100;
    valid_in = 1;
    @(posedge clk); #1;
    $display("Test 2: dout = %h (Expected: 0000000200)", dout);

    din_x = 16'h0080;
    din_w = 16'hFF00;
    valid_in = 1;
    @(posedge clk); #1;
    $display("Test 3: dout = %h (Expected: 0000000180)", dout);

    din_x = 16'hFE00;
    din_w = 16'hFF80;
    valid_in = 1;
    @(posedge clk); #1;
    $display("Test 4: dout = %h (Expected: 0000000280)", dout);
    
    valid_in = 0;
    #50;
    $display("Simulation Finished!");
    $finish;

end

initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_mac_unit);
end


endmodule