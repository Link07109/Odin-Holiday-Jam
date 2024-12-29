package game

import rl "vendor:raylib"
import "core:mem"
import "core:fmt"
import "ldtk"

scale := f32(6)
game_screen_width := i32(1920/scale)
game_screen_height := i32(1080/scale)

screen_width := f32(1920)
screen_height := f32(1080)

room_timer: Timer

main :: proc() {
    // -------------------------------------------------------------------------------------------------
    // MEMORY TRACKING
    // -------------------------------------------------------------------------------------------------
    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    defer {
        for _, entry in track.allocation_map {
            fmt.eprintf("%v leaked %v bytes \n", entry.location, entry.size)
        }

        for entry in track.bad_free_array {
            fmt.eprintf("%v bad free\n", entry.location)
        }

        mem.tracking_allocator_destroy(&track)
    }

    // init
    rl.InitWindow(i32(screen_width), i32(screen_height), "Odin Holiday Jam!")
    rl.SetWindowState({ .WINDOW_ALWAYS_RUN })
    rl.SetWindowIcon(load_image(.Icon))
    rl.SetTargetFPS(60)
    rl.SetExitKey(.GRAVE)

    rl.InitAudioDevice()
    rl.SetMasterVolume(0.25)

    target := rl.LoadRenderTexture(game_screen_width, game_screen_height)
    rl.SetTextureFilter(target.texture, .ANISOTROPIC_16X)
    rl.SetTextureWrap(target.texture, .CLAMP)

    title_screen_art := load_texture(.TitleScreen)
    tileset := load_texture(.Worldtiles)
    shader := load_shader(.Acerola)
    should_use_shader := false

    load_audio()
    load_rooms()
    rooms_map := map[string]^Room {
        "Start" = &room_start,
        "Tower_Base" = &room_tower_base,
        "Tower_2" = &room_tower_2,
        "Tower_3" = &room_tower_3,
        "Tower_4" = &room_tower_4,
        "Tower_5" = &room_tower_5,
        "Maze" = &room_maze
    }
    candidate_room := &room_start
    load_world(candidate_room, rooms_map)

    current_room = &room_title_screen
    current_music := &current_room.music
    gaming := false

    // main loop
    for (!rl.WindowShouldClose()) {
        screen_width = f32(rl.GetScreenWidth())
        screen_height = f32(rl.GetScreenHeight())

        if !rl.IsMusicStreamPlaying(current_room.music) {
            rl.StopMusicStream(current_music^)
            current_music^ = current_room.music
            current_music^.looping = true
            rl.PlayMusicStream(current_music^)
        }
        rl.UpdateMusicStream(current_music^)

        if current_room.name == "Title_Screen" {
            if rl.IsKeyPressed(.ENTER) {
                current_room = &room_tower_base
                gaming = true
                timer_start(&room_timer, 10)
                timer_start(&rect_timer, 0.4)
            }
        } else if current_room.name == "Win_Screen" {
            gaming = false
            if rl.IsKeyPressed(.ENTER) {
                current_room = &room_title_screen
            }
        } else {
            timer_update(&room_timer)
            if timer_done(&room_timer) {
                reset_tower_room()
                switch current_room.name {
                case "Tower_Base":
                    current_room = &room_tower_2
                case "Tower_2":
                    current_room = &room_tower_3
                case "Tower_3":
                    current_room = &room_tower_4
                case "Tower_4":
                    current_room = &room_tower_5
                case "Tower_5":
                    current_room = &room_win
                }
            }

            player_movement()
            timer_update(&rect_timer)
            if timer_done(&rect_timer) {
                disappear_update()
                timer_start(&black_timer, 0.4)
            }
            timer_update(&black_timer)
            if timer_done(&black_timer) {
                if rect_idx > 0 {
                    rect_array[rect_idx - 1].src = black_src
                }
            }
            for rect in rect_array {
                if rect.src == black_src {
                    if rl.CheckCollisionRecs(player_feet_collider, rect.dst) {
                        go_down_tower()
                    }
                }
            }
        }

        // draw
        rl.BeginTextureMode(target)
        rl.ClearBackground(rl.BLACK)
        if current_room.name == "Title_Screen" {
            rl.ClearBackground(rl.SKYBLUE)
            rl.DrawTexture(title_screen_art, 0, 0, rl.WHITE)
            rl.DrawText("Tower of Ascension", 70, 70, 20, rl.WHITE)
            rl.DrawText("Press [ENTER] to start", 70, 90, 10, rl.WHITE)
        } else if current_room.name == "Win_Screen" {
            rl.ClearBackground(rl.GREEN)
            rl.DrawText("You cleared the tower!", 70, 70, 20, rl.WHITE)
            rl.DrawText("Press [ENTER] to restart", 70, 90, 10, rl.WHITE)
        }
        if gaming {
            draw_tiles_ldtk(tileset, current_room.tile_data)
            draw_tiles_ldtk(tileset, current_room.custom_tile_data)
            //draw_entity_tiles_ldtk(tileset, current_room.entity_tile_offset, current_room.entity_tile_data)
            for rect in rect_array {
                rl.DrawTexturePro(tileset, rect.src, rect.dst, { 0, 0 }, 0, rl.WHITE)
            }
            handle_collisions(current_room)
            rl.DrawTexturePro(tileset, { 64, 0, 17, 18 }, { player_pos.x, player_pos.y, 17, 18 }, { 0, 0 }, 0, rl.WHITE)
            //rl.DrawRectangleRec(player_feet_collider, { 0, 255, 0, 125 })
            rl.DrawText(rl.TextFormat("%002.1f", room_timer.lifetime), 5, 10, 10, rl.WHITE)
        }
        rl.EndTextureMode()

        rl.BeginDrawing()
        if should_use_shader {
            rl.BeginShaderMode(shader)
        }
        rl.DrawTexturePro(
            target.texture,
            { 0, 0, f32(target.texture.width), -1 * f32(target.texture.height) },
            { screen_width - f32(game_screen_width)*scale, screen_height - f32(game_screen_height)*scale, f32(game_screen_width)*scale, f32(game_screen_height)*scale },
            { 0, 0 },
            0,
            rl.WHITE
        )
        if should_use_shader {
            rl.EndShaderMode()
        }
        rl.EndDrawing()
        free_all(context.temp_allocator)
    }

    // cleanup
    rl.CloseAudioDevice()
    rl.CloseWindow()

    for _, room in rooms_map {
        delete(room.entity_tile_data)
    }
    delete(rooms_map)
    free_all(context.temp_allocator)
}
