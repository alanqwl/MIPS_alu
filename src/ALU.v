`timescale 1ns/1ps

module ALU(instruction, regA, regB, final_result, flags);
    input [31:0] instruction;
    input signed [31:0] regA, regB;
    output signed [31:0] final_result;
    output [2:0] flags;       // Array

    reg[31:0] reg_u_A, reg_u_B;             // Unsigned version of regA and regB
    reg zero;
    reg negative;
    reg overflow;
    reg signed [31:0] result;
    reg signed [31:0] imme;
    reg unsigned [31:0] imme_u;
    reg [5:0] opcode, func;

    always @(instruction or regA or regB)
    begin
        zero = 1'b0;
        negative = 1'b0;
        overflow = 1'b0;
        opcode = instruction[31:26];
        func = instruction[5:0];
        case(opcode)
            6'b000000: begin                // R-type instruction
                case(func)      // function code
                6'b100000:begin     // add instruction
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) begin
                        result = regA + regA;
                        if (regA > 0 && result[31] == 1'b1) begin
                            overflow = 1'b1;
                        end
                        else if (regA < 0 && result[31] == 1'b0) begin
                            overflow = 1'b1;
                        end
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                        result = regA + regB;
                        if (regA > 0 && regB > 0 && result[31] == 1'b1) begin
                            overflow = 1'b1;
                        end
                        else if (regA < 0 && regB < 0 && result[31] == 1'b0) begin
                            overflow = 1'b1;
                        end
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                        result = regB + regB;
                        if (regB > 0 && result[31] == 1'b1) begin
                            overflow = 1'b1;
                        end
                        else if (regB < 0 && result[31] == 1'b0) begin
                            overflow = 1'b1;
                        end
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b100001:begin     // addu instruction
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) begin
                        result = regA + regA;
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                        result = regA + regB;
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                        result = regB + regB;
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b100100:begin     // Bitwise and
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) begin
                        result = regA & regA;
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                        result = regB & regB;
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                        result = regA & regB;  
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b100111:begin     // Bitwise nor
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) begin
                        result = ~(regA | regA);
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                        result = ~(regB | regB);
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                        result = ~(regA | regB);  
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b100101:begin     // Bitwise or
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) begin
                        result = regA | regA;
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                        result = regB | regB;
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                        result = regA | regB;  
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b000000:begin     // shift left logical
                    if (instruction[20:16] == 5'b00000) begin
                        result = regA << instruction[10:6];
                    end
                    else if (instruction[20:16] == 5'b00001) begin
                        result = regB << instruction[10:6];
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b000100: begin        // shift left logical variable
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) begin
                        result = regA << regA[4:0];
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000) begin
                        result = regA << regB[4:0];
                    end
                    else if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) begin
                        result = regB << regA[4:0];
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                        result = regB << regB[4:0];
                    end
                    else begin
                        $display("Unexpected register address");
                    end
                end
                6'b101010: begin        // set on less than
                    if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000) begin
                        if (regB < regA) begin
                            result = regB - regA;
                            negative = 1'b1;
                        end
                        else begin
                            result = regB - regA;
                        end
                    end
                    else if(instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) begin
                        if (regA < regB) begin
                            result = regA - regB;
                            negative = 1'b1;
                        end
                        else begin
                            result = regA - regB;
                        end
                    end
                    else if((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001)) begin
                            result = 0;
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b101011: begin        // Set on less than unsigned
                    reg_u_A = regA;
                    reg_u_B = regB;
                    if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000) begin
                        if (reg_u_B < reg_u_A) begin
                            result = reg_u_B - reg_u_A;
                            negative = 1'b1;
                        end
                        else begin
                            result = reg_u_B - reg_u_A;
                        end
                    end
                    else if(instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) begin
                        if (reg_u_A < reg_u_B) begin
                            result = reg_u_A - reg_u_B;
                            negative = 1'b1;
                        end
                        else begin
                            result = reg_u_A - reg_u_B;
                        end
                    end
                    else if((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                            instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001) begin
                            result = 0;
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b000011: begin        // shift right arithmetic
                    if (instruction[20:16] == 5'b00000) begin
                        result = regA >>> instruction[10:6];
                    end
                    else if (instruction[20:16] == 5'b00001) begin
                        result = regB >>> instruction[10:6];
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b000111: begin        // shift right arithmetic variable.
                    if (instruction[20:16] == 5'b00000 && instruction[25:21] == 5'b00001) begin
                        result = regA >>> regB[4:0];
                    end
                    else if (instruction[20:16] == 5'b00001 && instruction[25:21] == 5'b00000) begin
                        result = regB >>> regA[4:0];
                    end
                    else if (instruction[20:16] == 5'b00000 && instruction[25:21] == 5'b00000) begin
                        result = regA >>> regA[4:0];
                    end
                    else if (instruction[20:16] == 5'b00001 && instruction[25:21] == 5'b00001) begin
                        result = regB >>> regB[4:0];
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b000010: begin        // shift right logical
                    if (instruction[20:16] == 5'b00000) begin
                        result = regA >> instruction[10:6];
                    end
                    else if (instruction[20:16] == 5'b00001) begin
                        result = regB >> instruction[10:6];
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b000110: begin        // shift right logiacl variable
                    if (instruction[20:16] == 5'b00000 && instruction[25:21] == 5'b00001) begin
                        result = regA >> regB[4:0];
                    end
                    else if (instruction[20:16] == 5'b00001 && instruction[25:21] == 5'b00000) begin
                        result = regB >> regA[4:0];
                    end
                    else if (instruction[20:16] == 5'b00000 && instruction[25:21] == 5'b00000) begin
                        result = regA >> regA[4:0];
                    end
                    else if (instruction[20:16] == 5'b00001 && instruction[25:21] == 5'b00001) begin
                        result = regB >> regB[4:0];
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b100010: begin        // subtract
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) begin
                        result = regA - regB;
                        if (regA > 0 && regB < 0 && result[31] == 1'b1) begin
                            overflow = 1'b1;
                        end
                        else if (regA < 0 && regB > 0 && result[31] == 1'b0) begin
                            overflow = 1'b1;
                        end
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000) begin
                        result = regB - regA;
                        if (regB > 0 && regA < 0 && result[31] == 1'b1) begin
                            overflow = 1'b1;
                        end
                        else if (regB < 0 && regA > 0 && result[31] == 1'b0) begin
                            overflow = 1'b1;
                        end
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001)) begin
                        result = 32'b0;
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b100011: begin        // Subtract unsigned
                    if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) begin
                        result = regA - regB;
                    end
                    else if (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000) begin
                        result = regB - regA;
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001)) begin
                        result = 32'b0;
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end
                6'b100110: begin        // Bitwise exclusive or
                    if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001)) begin
                        result = 32'b0;
                    end
                    else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                            (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                        result = regA ^ regB;
                    end
                    else begin
                        $display("Unexpected register address.");
                    end
                end 
                default: $display("Unexpected R-type instruction input.");
                endcase 
            end
            6'b001000: begin        // Add intermediate
                imme = {{16{instruction[15]}}, instruction[15:0]};      // Signed extension
                if (instruction[25:21] == 5'b00000) begin
                    result = regA + imme;
                    if (regA > 0 && imme > 0 && result[31] == 1) begin
                        overflow = 1'b1;
                    end
                    else if (regA < 0 && imme < 0 && result[31] == 0) begin
                        overflow = 1'b1;
                    end
                end
                else if(instruction[25:21] == 5'b00001) begin
                    result = regB + imme;
                    if (regB > 0 && imme > 0 && result[31] == 1) begin
                        overflow = 1'b1;
                    end
                    else if (regB < 0 && imme < 0 && result[31] == 0) begin
                        overflow = 1'b1;
                    end
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b001001: begin        // Add immediate unsigned
                imme = {{16{instruction[15]}}, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    result = regA + imme;    
                end
                else if (instruction[25:21] == 5'b00001) begin
                    result = regB + imme;
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b000100: begin        // branch on equal
                imme = {{14{instruction[15]}}, instruction[15:0], 2'b00};
                if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) ||
                    (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00000)) begin
                    if (regA - regB == 0) begin
                        zero = 1'b1;
                        result = imme;
                    end
                    else begin
                        result = 32'd4;
                    end
                end
                else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                        (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001)) begin
                    zero = 1'b1;
                    result = imme;
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b000101: begin        // branch on not equal
                imme = {{14{instruction[15]}}, instruction[15:0], 2'b00};
                if (instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00001) begin
                    if (regA - regB == 0) begin
                        zero = 1'b1;
                        result = 32'd4;
                    end
                    else begin
                        result = imme;
                    end
                end
                else if ((instruction[25:21] == 5'b00000 && instruction[20:16] == 5'b00000) ||
                        (instruction[25:21] == 5'b00001 && instruction[20:16] == 5'b00001)) begin
                    zero = 1'b1;
                    result = 32'd4;
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b100011: begin        // load word
                imme = {{16{instruction[15]}}, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    result = regA + imme;
                end
                else if (instruction[25:21] == 5'b00001) begin
                    result = regB + imme;
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b001101: begin        // bitwise or immediate
                imme = {16'b0, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    result = regA | imme;
                end
                else if (instruction[25:21] == 5'b00001) begin
                    result = regB | imme;
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b001010: begin        // Set on less than immediate
                imme = {{16{instruction[15]}}, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    if (regA < imme) begin
                        negative = 1'b1;
                        result = regA - imme;
                    end
                    else begin
                        result = regA - imme;
                    end
                end
                else if (instruction[25:21] == 5'b00001) begin
                    if (regB < imme) begin
                        negative = 1'b1;
                        result = regB - imme;
                    end
                    else begin
                        result = regB - imme;
                    end
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b001011: begin        // Set on less than immediate unsigned
                imme_u = {{16{instruction[15]}}, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    reg_u_A = regA;
                    if (reg_u_A < imme_u) begin
                        negative = 1'b1;
                        result = reg_u_A - imme_u;
                    end
                    else begin
                        result = reg_u_A - imme_u;
                    end
                end
                else if (instruction[25:21] == 5'b00001) begin
                    reg_u_B = regB;
                    if (reg_u_B < imme_u) begin
                        negative = 1'b1;
                        result = reg_u_B - imme_u;
                    end
                    else begin
                        result = reg_u_B - imme_u;
                    end
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b101011: begin        // Store word
                imme = {{16{instruction[15]}}, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    result = regA + imme;
                end
                else if (instruction[25:21] == 5'b00001) begin
                    result = regB + imme;
                end
                else begin
                    $display("Unexpected register address.");
                end
            end
            6'b001110: begin        // Bitwise exclusive or immediate.
                imme = {16'b0, instruction[15:0]};
                if (instruction[25:21] == 5'b00000) begin
                    result = regA ^ imme;
                end
                else if (instruction[25:21] == 5'b00001) begin
                    result = regB ^ imme;
                end
            end
        endcase
    end

    assign flags[2] = zero;
    assign flags[1] = negative;
    assign flags[0] = overflow;
    assign final_result = result;
endmodule