`timescale 1ns / 1ps

module pl_branch_prediction(
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic is_branch_instruction,
    input  logic branch_taken_actual, // 1 = branch taken, 0 = branch not taken
    output logic predicted_taken     // 1 = predicted taken, 0 = predicted not taken
);
    typedef enum logic [1:0] {
        SNT = 2'b00, // Strongly Not Taken
        WNT = 2'b01, // Weakly Not Taken
        WT  = 2'b10, // Weakly Taken
        ST  = 2'b11  // Strongly Taken
    } state_t;

    state_t current_state, next_state;

    always_comb begin
        case (current_state)
            SNT: next_state = branch_taken_actual ? WNT : SNT;
            WNT: next_state = branch_taken_actual ? WT  : SNT;
            WT:  next_state = branch_taken_actual ? ST  : WNT;
            ST:  next_state = branch_taken_actual ? ST  : WT;
            default: next_state = SNT;
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset)
            current_state <= SNT;
        else if (enable && is_branch_instruction)
            current_state <= next_state;
    end

    always_comb begin
        case (current_state)
            SNT, WNT: predicted_taken = 0;
            WT,  ST:  predicted_taken = 1;
        endcase
    end
endmodule
