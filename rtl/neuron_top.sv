module neuron_top#(parameter [12:0] WEIGHT_OFFSET = 0) (
    input clk,
    input rst_n,
    input start,
    input signed [15:0] din_x,
    output signed [39:0] dout,
    output done
);

logic [12:0] address;
logic signed [15:0] w_data;
logic vmac;
logic c_acc;
//logic signed [39:0] mac_out;

controller #(.OFFSET(WEIGHT_OFFSET)) c (.clk(clk), .rst_n(rst_n), .start(start), .done(done),
        .clr_acc(c_acc), .address(address), .valid_mac(vmac)
    );

weight_memory wm (.clk(clk), .address(address), .dout_w(w_data));

mac_unit mu (.clk(clk), .rst_n(rst_n), .din_x(din_x),
             .din_w(w_data), .valid_in(vmac), .clr_acc(c_acc), .dout(dout));


endmodule