module mac_unit (
    input clk,
    input rst_n,
    input signed [15:0] din_x,
    input signed [15:0] din_w,
    input valid_in,
    input clr_acc,
    output logic signed [39:0] dout
);

wire signed [31:0] mult_result;

always_ff @(posedge clk  or negedge rst_n) begin
    if (!rst_n) begin
        dout <= 0;
    end

    else if (clr_acc) begin
        dout <= 0;
    end
    
    else if (valid_in) begin
        dout <= dout + mult_result;
    end
end

assign mult_result = ($signed(din_x) * $signed(din_w)) >>> 12;

endmodule