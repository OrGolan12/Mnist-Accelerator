module layer_top(
    input clk,
    input rst_n,
    input start,
    input signed [15:0] d_in,
    output [3:0] prediction,
    output layer_done
);

logic signed [39:0] neuron_outputs [9:0];
logic [9:0] neuron_dones;
    
genvar i;
generate
    for (i = 0; i < 10; i = i + 1) begin
        neuron_top #(.WEIGHT_OFFSET(i * 784)) nt (
            .clk(clk),
            .rst_n(rst_n),
            .start(start),
            .din_x(d_in),
            .dout(neuron_outputs[i]),
            .done(neuron_dones[i]));
        end
endgenerate

logic signed [39:0] max_val;
logic [3:0] max_idx;

always_comb begin
    max_val = neuron_outputs[0];
    max_idx = 0;
    for(int i = 1; i < 10; i = i + 1) begin
        if(neuron_outputs[i] > max_val) begin
            max_val = neuron_outputs[i];
            max_idx = i;
        end
    end
end

assign layer_done = &neuron_dones;
assign prediction = max_idx;

endmodule