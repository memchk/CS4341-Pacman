`default_nettype none
import project::coord_t;
module game_state (
    input logic i_clk, i_en, i_rst,
    input logic [3:0] i_joystick,
    output coord_t o_pacman,
    output logic [2:0] o_pacman_dir
);
import project::*;

typedef enum {
    IDLE,
    LATCH_INPUT,
    MOVEMENT,
    COLLISION,
    UPDATE_OUTPUTS
} state_t;

state_t state, next_state;

logic [3:0]     r_joystick;
logic [1:0]     r_en_edge;
coord_t         r_next_pos;
logic [2:0]     r_next_dir;

logic will_collide;
logic [5:0] map_x;
logic [4:0] map_y;

map_ram collision_map (
    .i_clk(i_clk),
    .i_en(i_en),
    .i_write(1'b0),
    .i_tile_x(map_x),
    .i_tile_y(map_y),
    .o_tile_value(will_collide)
);

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
            next_state = COLLISION;
        end
        COLLISION: begin
            next_state = UPDATE_OUTPUTS;
        end
        UPDATE_OUTPUTS: begin
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
        o_pacman.x <= 64;
        o_pacman.y <= 64;
        r_next_pos.x <= 64;
        r_next_pos.y <= 64;
        state <= IDLE;

    end else if (state == MOVEMENT) begin
        case (1'b1)
            // Up.
            r_joystick[3]: begin
                r_next_pos.y <= o_pacman.y - 4;
                r_next_dir <= 3'b101;
            end
            // Right.
            r_joystick[2]: begin
                r_next_pos.x <= o_pacman.x + 4;
                r_next_dir <= 3'b000;
            end
            // Down.
            r_joystick[1]: begin
                r_next_pos.y <= o_pacman.y + 4;
                r_next_dir <= 3'b001;
            end
            // Left.
            r_joystick[0]: begin
                r_next_pos.x <= o_pacman.x - 4;
                r_next_dir <= 3'b010;
            end
        endcase

        // Handle screen wrapping.
        if (r_joystick[2] && o_pacman.x > 799) begin
            r_next_pos.x <= '0;
        end

        if (r_joystick[0] && o_pacman.x > 799) begin
            r_next_pos.x <= 799;
        end

        if (r_joystick[1] && o_pacman.y > 599) begin
            r_next_pos.y <= '0;
        end

        if (r_joystick[3] && o_pacman.y > 599) begin
            r_next_pos.y <= 599;
        end
    end else if (state == COLLISION) begin
        case (1'b1)
            // Up.
            r_joystick[3]: begin
                map_y <= 5'((r_next_pos.y - 10'd8) >> 4);
                map_x <= 6'((r_next_pos.x + 10'd8) >> 4);
            end
            // Right, look 16 right, 8 down.
            r_joystick[2]: begin
                map_y <= 5'((r_next_pos.y + 10'd8) >> 4);
                map_x <= 6'((r_next_pos.x + 10'd16) >> 4);
            end
            // Down, look 8 to the right, 24 down (8 down from the bottom) 
            r_joystick[1]: begin
                map_y <= 5'((r_next_pos.y + 10'd24) >> 4);
                map_x <= 6'((r_next_pos.x + 10'd8) >> 4);
            end
            // Left, look 8 to the left, and in the middle of pacman
            r_joystick[0]: begin
                map_y <= 5'((r_next_pos.y + 10'd8) >> 4);
                map_x <= 6'((r_next_pos.x - 10'd8) >> 4);
            end
        endcase
    end else if (state == UPDATE_OUTPUTS) begin
        if (!will_collide) begin
            o_pacman <= r_next_pos;
        end
        o_pacman_dir <= r_next_dir;
    end
end

endmodule