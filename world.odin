package game

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/json"
import "ldtk"

Tile :: struct {
    src: rl.Vector2,
    dst: rl.Vector2,
    flip_x: bool,
    flip_y: bool,
}

Entity :: struct {
    identifier: string,
    src: rl.Vector2,
    dst: rl.Vector2,
    width: int,
    height: int,
}

Room :: struct {
    name: string,
    music: rl.Music,

    entity_tile_offset: rl.Vector2,
    entity_tile_data: [dynamic]Entity,
    custom_tile_data: [240]Tile,
    tile_data: [240]Tile,
    collision_tiles: [240]u8,
}

room_title_screen,
room_game_over,
room_win,
room_start,
room_tower_base,
room_tower_2,
room_tower_3,
room_tower_4,
room_tower_5,
room_maze: Room

current_room: ^Room

music_title,
music_game,
music_win: rl.Music

load_audio :: proc() {
    music_title = load_music(.Ascent)
    music_game = load_music(.Minigame)
    music_win = load_music(.GameOver)
}

load_rooms :: proc() {
    room_title_screen = Room {
        name = "Title_Screen",
        music = music_title
    }
    room_game_over = Room {
        name = "Game_Over_Screen",
    }
    room_win = Room {
        name = "Win_Screen",
        music = music_win
    }

    room_start = Room {
        name = "Start",
    }
    room_tower_base = Room {
        name = "Tower_Base",
        music = music_game
    }
    room_tower_2 = Room {
        name = "Tower_2",
        music = music_game
    }
    room_tower_3 = Room {
        name = "Tower_3",
        music = music_game
    }
    room_tower_4 = Room {
        name = "Tower_4",
        music = music_game
    }
    room_tower_5 = Room {
        name = "Tower_5",
        music = music_game
    }
    room_maze = Room {
        name = "Maze"
    }
}

reset_tower_room :: proc() {
    player_pos = { 320/2, 180/2 }
    player_feet_collider.x = player_pos.x + 2
    player_feet_collider.y = player_pos.y + 11
    for &rect in rect_array {
        rect = { { 0, 0, 0, 0 }, { 0, 0, 0, 0 } }
    }
    rect_idx = 0
    timer_start(&room_timer, 10)
}

go_down_tower :: proc() {
    reset_tower_room()
    switch current_room.name {
    case "Tower_Base":
        current_room = &room_tower_base
    case "Tower_2":
        current_room = &room_tower_base
    case "Tower_3":
        current_room = &room_tower_2
    case "Tower_4":
        current_room = &room_tower_3
    case "Tower_5":
        current_room = &room_tower_4
    }
}

load_world :: proc(candidate_room: ^Room, rooms_map: map[string]^Room) {
    if project, ok := load_level_data(.World).?; ok {
        fmt.println("---- Successfully loaded ldtk json!!!")

        candidate_room := candidate_room
        for level in project.levels {
            level_name := level.identifier

            if level_name not_in rooms_map {
                continue
            }
            if level_name != candidate_room.name {
                candidate_room = rooms_map[level_name]
            }
            tile_size = project.default_grid_size

            for layer in level.layer_instances {
                switch layer.type {
                    case .IntGrid: // floor + walls, collisions
                        candidate_room.tile_data = load_tile_layer_ldtk(layer.auto_layer_tiles)

                        for val, idx in layer.int_grid_csv {
                            candidate_room.collision_tiles[idx] = u8(val)
                        }
                    case .Entities: // items, interactables
                        candidate_room.entity_tile_data = load_entity_layer_ldtk(candidate_room, rooms_map, layer, layer.entity_instances, &candidate_room.entity_tile_offset)

                    case .Tiles: // custom tiles
                        candidate_room.custom_tile_data = load_tile_layer_ldtk(layer.grid_tiles)
                    case .AutoLayer:
                }
            }
        }
    } else {
        fmt.println("---- ERROR LOADING LDTK JSON!!!!")
    }
}

tile_size := 16
tile_columns := 20
tile_rows := 12
offset: rl.Vector2 = { 8, 8 }

load_entity_layer_ldtk :: proc(room: ^Room, rooms_map: map[string]^Room, layer: ldtk.Layer_Instance, iter: []ldtk.Entity_Instance, tile_offset: ^rl.Vector2) -> [dynamic]Entity {
    tile_offset.x = f32(layer.px_total_offset_x)
    tile_offset.y = f32(layer.px_total_offset_y)

    tiles := make([dynamic]Entity, len(iter))
    door_counter: u8
    spike_counter: u8

    for val, idx in iter {
        entity_tile := val.tile.? or_else { x = 0, y = 0 }
        tiles[idx].src.x = f32(entity_tile.x)
        tiles[idx].src.y = f32(entity_tile.y)

        tiles[idx].dst.x = f32(val.px.x)
        tiles[idx].dst.y = f32(val.px.y)

        tiles[idx].width = val.width
        tiles[idx].height = val.height
        tiles[idx].identifier = val.identifier
    }
    return tiles
}

load_tile_layer_ldtk :: proc(iter: []ldtk.Tile_Instance) -> [240]Tile {
    tiles: [240]Tile
    for val, idx in iter {
        f := val.f
        tiles[idx].flip_x = bool(f & 1)
        tiles[idx].flip_y = bool(f & 2)

        tiles[idx].src.x = f32(val.src.x)
        tiles[idx].src.y = f32(val.src.y)
        tiles[idx].dst.x = f32(val.px.x)
        tiles[idx].dst.y = f32(val.px.y)
    }
    return tiles
}

draw_entity_tiles_ldtk :: proc(tileset: rl.Texture2D, tile_offset: rl.Vector2, tiles: [dynamic]Entity) {
    for val in tiles {
        src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
        dst_rect := rl.Rectangle {val.dst.x + offset.x + tile_offset.x, val.dst.y + offset.y + tile_offset.y, f32(val.width), f32(val.height)}
        rl.DrawTexturePro(tileset, src_rect, dst_rect, { f32(tile_size/2), f32(tile_size/2) }, 0, rl.WHITE)
    }
}

draw_tiles_ldtk :: proc(tileset: rl.Texture2D, tiles: [240]Tile) {
    for val in tiles {
        src_rect := rl.Rectangle { val.src.x, val.src.y, 16, 16 }
        if val.flip_x {
            src_rect.width *= -1.0
        }
        if val.flip_y {
            src_rect.height *= -1.0
        }
        dst_rect := rl.Rectangle { val.dst.x + offset.x, val.dst.y + offset.y, 16, 16 }
        rl.DrawTexturePro(tileset, src_rect, dst_rect, { 8, 8 }, 0, rl.WHITE)
    }
}

handle_collisions :: proc(current_room: ^Room) {
    for row := 0; row < tile_rows; row += 1 {
        for column := 0; column < tile_columns; column += 1 {
            collider := current_room.collision_tiles[row * tile_columns + column]

            if collider == 0 || collider == 3 {
                continue
            }
            coll := rl.Rectangle { f32(column * tile_size) + offset.x - f32(tile_size) / 2.0, f32(row * tile_size) + offset.y - f32(tile_size) / 2.0, f32(tile_size), f32(tile_size) }
            //rl.DrawRectangleRec(coll, { 255, 0, 0, 75 })
            player_wall_collision(coll)
        }
    }
}
