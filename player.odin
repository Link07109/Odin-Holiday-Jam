package game

import rl "vendor:raylib"
import "core:math"

player_run_speed := f32(60)
player_pos := rl.Vector2 { 320/2, 180/2 }
player_vel: rl.Vector2
player_feet_collider := rl.Rectangle { 0, 0, 12, 6 }

player_movement :: proc() {
    if rl.IsKeyDown(.W) {
        player_vel.y = -1
    } else if rl.IsKeyDown(.S) {
        player_vel.y = 1
    } else {
        player_vel.y = 0
    }

    if rl.IsKeyDown(.D) {
        player_vel.x = 1
    } else if rl.IsKeyDown(.A) {
        player_vel.x = -1
    } else {
        player_vel.x = 0
    }
    player_pos += player_vel * player_run_speed * rl.GetFrameTime()
    player_feet_collider.x = player_pos.x + 2
    player_feet_collider.y = player_pos.y + 11
}

player_edge_collision :: proc() {
    if player_pos.x <= 6 {
        player_pos.x = 7
        player_feet_collider.x = 7 - 6
    }
    if player_pos.x >= 218 {
        player_pos.x = 217
        player_feet_collider.x = 217 - 6
    }
    if player_pos.y <= 19  {
        player_pos.y = 20
        player_feet_collider.y = 20 - 9
    }
    if player_pos.y >= 129 {
        player_pos.y = 128
        player_feet_collider.y = 128 - 9
    }
}

// Minkowski difference
player_wall_collision :: proc(coll: rl.Rectangle) {
    if rl.CheckCollisionRecs(player_feet_collider, coll) {
        //fmt.println("---- Collided with wall!")

        // Calculation of centers of rectangles
        center1: rl.Vector2 = { player_feet_collider.x + player_feet_collider.width / 2, player_feet_collider.y + player_feet_collider.height / 2 }
        center2: rl.Vector2 = { coll.x + coll.width / 2, coll.y + coll.height / 2 }

        // Calculation of the distance vector between the centers of the rectangles
        delta := center1 - center2

        // Calculation of half-widths and half-heights of rectangles
        hs1: rl.Vector2 = { player_feet_collider.width*0.5, player_feet_collider.height*0.5 }
        hs2: rl.Vector2 = { coll.width*0.5, coll.height*0.5 }

        // Calculation of the minimum distance at which the two rectangles can be separated
        min_dist_x := hs1.x + hs2.x - abs(delta.x)
        min_dist_y := hs1.y + hs2.y - abs(delta.y)

        // Adjusted object position based on minimum distance
        //fmt.printf("player coll before: %v\n", player_feet_collider)
        if (min_dist_x < min_dist_y) {
            player_pos.x += math.copy_sign(min_dist_x, delta.x)
            player_feet_collider.x += math.copy_sign(min_dist_x, delta.x)
        } else {
            player_pos.y += math.copy_sign(min_dist_y, delta.y)
            player_feet_collider.y += math.copy_sign(min_dist_y, delta.y)
        }
        //fmt.printf("player coll after: %v\n", player_feet_collider)
    }
}
