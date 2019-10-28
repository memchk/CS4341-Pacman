`default_nettype none
import project::coord_t;
module game_state (
    input logic i_clk, i_en, i_rst,
    input logic [3:0] i_joystick,
    output coord_t o_pacman
);
import project::*;

typedef enum {
    IDLE,
    LATCH_INPUT,
    MOVEMENT
} state_t;

state_t state, next_state;

logic [3:0] r_joystick;

logic [1:0] r_en_edge;

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
        o_pacman.x <= '0;
        o_pacman.y <= '0;
    end else if (state == MOVEMENT) begin
        unique case (1'b1)
            // Up.
            r_joystick[3]: begin
                o_pacman.y <= o_pacman.y - 4;
            end
            // Right.
            r_joystick[2]: begin
                o_pacman.x <= o_pacman.x + 4;
            end
            // Down.
            r_joystick[1]: begin
                o_pacman.y <= o_pacman.y + 4;
            end
            // Left.
            r_joystick[0]: begin
                o_pacman.x <= o_pacman.x - 4;
            end
        endcase
    end
end

endmodule