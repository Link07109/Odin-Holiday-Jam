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
    rl.SetTargetFPS(60)
    rl.SetExitKey(.GRAVE)

    rl.InitAudioDevice()
    rl.SetMasterVolume(0.25)

    target := rl.LoadRenderTexture(game_screen_width, game_screen_height)
    rl.SetTextureFilter(target.texture, .ANISOTROPIC_16X)
    rl.SetTextureWrap(target.texture, .CLAMP)

    tileset := load_texture(.Worldtiles)
    shader := rl.LoadShader(nil, "acerola.frag")
    should_use_shader := false

    load_rooms()
    rooms_map := map[string]^Room {
        "Start" = &room_start,
    }
    candidate_room := &room_start
    load_world(candidate_room, rooms_map)

    current_room = &room_start

    music := rl.LoadMusicStream("Resources/Audio/Music/balcony.wav")
    music.looping = true

    // main loop
    for (!rl.WindowShouldClose()) {
        screen_width = f32(rl.GetScreenWidth())
        screen_height = f32(rl.GetScreenHeight())

        if !rl.IsMusicStreamPlaying(music) {
            rl.PlayMusicStream(music)
        }
        rl.UpdateMusicStream(music)

        player_movement()

        // draw
        rl.BeginTextureMode(target)
        rl.ClearBackground(rl.BLACK)
        draw_tiles_ldtk(tileset, current_room.tile_data)
        draw_tiles_ldtk(tileset, current_room.custom_tile_data)
        handle_collisions(current_room)
        //draw_entity_tiles_ldtk(tileset, current_room.entity_tile_offset, current_room.entity_tile_data)
        rl.DrawTexturePro(tileset, { 64, 0, 17, 18 }, { player_pos.x, player_pos.y, 17, 18 }, { 0, 0 }, 0, rl.WHITE)
        //rl.DrawRectangleRec(player_feet_collider, { 0, 255, 0, 125 })
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
