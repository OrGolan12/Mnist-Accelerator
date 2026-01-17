module weight_memory(
    input clk,
    input [12:0] address,
    output logic signed [15:0] dout_w
);

logic signed [15:0] arr [8191:0];

initial $readmemh("data/weights.mem", arr);

always_ff @(posedge clk) begin
    dout_w <= arr[address];
end

endmodule