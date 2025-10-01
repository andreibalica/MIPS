`timescale 1ns / 1ps

module sc_branch_control(
    input  logic zero,
    input  logic branch_eq,
    input  logic branch_ne,
    output logic pc_src
    );

    assign pc_src = (zero & branch_eq) | (~zero & branch_ne);

endmodule
