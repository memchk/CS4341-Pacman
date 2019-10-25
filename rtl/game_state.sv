module game_state #(
    parameter SCREEN_WIDTH = 800,
    parameter SCREEN_HEIGHT = 600
)(
    input logic i_clk, i_en, i_rst,
    input logic [3:0] i_joystick,
    output logic [clogb2(SCREEN_WIDTH):0] pacman_x,
    output logic [clogb2(SCREEN_HEIGHT):0] pacman_y
);

typedef enum {
    IDLE,
    LATCH_INPUT,
    MOVEMENT
} state_t;

state_t state, next_state;

logic [3:0] r_joystick;

logic [1:0] r_en_edge;

// Taken from https://stackoverflow.com/a/5276596
// Function to calculate ceil(log2(x)) of a number,
// useful for determining bit widths for registers.
function integer clogb2;
    input [31:0] value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
            value = value >> 1;
        end
    end
endfunction


// State machine drivers.
always_comb begin
    case (state)
        IDLE: begin
            if (r_en_edge == 2'b01) begin
                next_state = LATCH_INPUT;
            end
        end
        LATCH_INPUT: begin
            next_state = MOVEMENT;
        end
        MOVEMENT: begin
            next_state = IDLE;
        end
    endcase
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
    end else if (i_en) begin
        state <= next_state;
        if(state == LATCH_INPUT) begin
            r_joystick <= i_joystick;
        end
    end
end

// Edge detect the enable system to only allow the state machine
// to leave IDLE once per enable cycle.
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        r_en_edge <= '0;
    end else begin
        r_en_edge <= {r_en_edge[0], i_en};
    end
end

// Input to Movement Processing.
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        pacman_x <= '0;
        pacman_y <= '0;
    end else if (state == MOVEMENT) begin
        unique case (1'b1)
            // Up.
            r_joystick[3]: begin
                pacman_y <= pacman_y - 8;
            end
            // Right.
            r_joystick[2]: begin
                pacman_x <= pacman_x + 8;
            end
            // Down.
            r_joystick[1]: begin
                pacman_y <= pacman_y + 8;
            end
            // Left.
            r_joystick[0]: begin
                pacman_x <= pacman_x - 8;
            end
        endcase
    end
end

endmodule