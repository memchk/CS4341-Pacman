import project::coord_t;
module game_state (
    input logic i_clk, i_en, i_rst,
    input logic [3:0] i_joystick,
    output coord_t o_becman,
    output logic [2:0] o_becman_dir
);
import project::*;

typedef enum logic [5:0] {
    IDLE,
    LATCH_INPUT,
    MOVEMENT,
    COLLISION,
    SNAP_POS,
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
            end else begin
                next_state = IDLE;
            end
        end
        LATCH_INPUT: begin
            next_state = MOVEMENT;
        end
        MOVEMENT: begin
            next_state = COLLISION;
        end
        COLLISION: begin
            next_state = SNAP_POS;
        end
        SNAP_POS: begin
            next_state = UPDATE_OUTPUTS;
        end
        UPDATE_OUTPUTS: begin
            next_state = IDLE;
        end
        default:
            next_state = IDLE;
    endcase
end

always_ff @(posedge i_clk) begin
    if (i_rst) begin
        state <= IDLE;
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

// Main Movement Processing.
always_ff @(posedge i_clk) begin
    if (i_rst) begin
        o_becman.x <= 64;
        o_becman.y <= 64;
        r_next_pos.x <= 64;
        r_next_pos.y <= 64;
    end else if (state == MOVEMENT) begin
    // Perform basic movement calculations based on joystick input.
    // Also associate a direction with it for sprite processing.
        case (1'b1)
            // Up.
            r_joystick[3]: begin
                r_next_pos.y <= o_becman.y - 2;
                r_next_dir <= 3'b101;
            end
            // Right.
            r_joystick[2]: begin
                r_next_pos.x <= o_becman.x + 2;
                r_next_dir <= 3'b000;
            end
            // Down.
            r_joystick[1]: begin
                r_next_pos.y <= o_becman.y + 2;
                r_next_dir <= 3'b001;
            end
            // Left.
            r_joystick[0]: begin
                r_next_pos.x <= o_becman.x - 2;
                r_next_dir <= 3'b010;
            end
        endcase

        // Handle screen wrapping.
        if (r_joystick[2] && o_becman.x > 799) begin
            r_next_pos.x <= '0;
        end

        if (r_joystick[0] && o_becman.x > 799) begin
            r_next_pos.x <= 799;
        end

        if (r_joystick[1] && o_becman.y > 495) begin
            r_next_pos.y <= '0;
        end

        if (r_joystick[3] && o_becman.y > 495) begin
            r_next_pos.y <= 495;
        end

    end else if (state == COLLISION) begin
    // Look at the previously calculated new pos
        case (1'b1)
            // Up.
            r_joystick[3]: begin
                map_y <= 5'((r_next_pos.y) >> 4);
                map_x <= 6'((r_next_pos.x + 10'd8) >> 4);
            end
            // Right, look 16 right, 8 down.
            r_joystick[2]: begin
                map_y <= 5'((r_next_pos.y + 10'd8) >> 4);
                map_x <= 6'((r_next_pos.x + 10'd16) >> 4);
            end
            // Down, look 8 to the right, 16 down
            r_joystick[1]: begin
                map_y <= 5'((r_next_pos.y + 10'd16) >> 4);
                map_x <= 6'((r_next_pos.x + 10'd8) >> 4);
            end
            // Left, look 8 to the left, and in the middle of becman
            r_joystick[0]: begin
                map_y <= 5'((r_next_pos.y + 10'd8) >> 4);
                map_x <= 6'((r_next_pos.x) >> 4);
            end
        endcase
    end else if (state == SNAP_POS) begin
        if(o_becman_dir != r_next_dir) begin
            case (1'b1)
                (r_joystick[0] | r_joystick[2]):
                    r_next_pos.y[3:0] <= {4{&r_next_pos.y[3:2]}};                
                (r_joystick[1] | r_joystick[3]):
                    r_next_pos.x[3:0] <= {4{&r_next_pos.x[3:2]}};
            endcase
        end
    end else if (state == UPDATE_OUTPUTS) begin
        if (!will_collide) begin
            o_becman <= r_next_pos;
        end
        o_becman_dir <= r_next_dir;
    end
end

endmodule