module controller #(parameter [12:0] OFFSET = 0) (
    input clk,
    input rst_n,
    input start,
    output logic done,
    output logic clr_acc,
    output logic [12:0] address,
    output logic valid_mac
);

typedef enum logic [1:0] {IDLE, INIT, CALC, DONE} state_t;
state_t curr, next;
logic [9:0] counter;


//counter logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        counter <= 0;
    else if (curr == INIT)
        counter <= 0;
    else if (curr == CALC)
        counter <= counter + 1;
end

always_comb begin
    if (curr == CALC) 
        valid_mac = 1'b1;
    else
        valid_mac = 1'b0;
end

//state transition
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        curr <= IDLE;
    else
        curr <= next;
end

//next_state logic
always_comb begin
    next = curr;

    case(curr)
        IDLE: begin
            if(start)
                next = INIT;
        end

        INIT: begin
                next = CALC;
        end

        CALC: begin
            if (counter == 10'd783)
                next = DONE;
        end

        DONE: begin
            next = IDLE;
        end
    endcase 
end

assign address = counter + OFFSET;
assign clr_acc = (curr == INIT);
assign done = (curr == DONE);

endmodule