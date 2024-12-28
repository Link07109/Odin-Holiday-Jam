/**
  * Modified version of Karl Zylinski's 
  * code from his game CAT & ONION
  */

package assets_builder

import "core:fmt"
import "core:os"
import "core:strings"
import "core:path/slashpath"
import "core:hash"

dir_path_to_file_infos :: proc(path: string) -> []os.File_Info {
    d, derr := os.open(path, os.O_RDONLY)
    if derr != 0 {
        panic("open failed")
    }
    defer os.close(d)

    {
        file_info, ferr := os.fstat(d)
        defer os.file_info_delete(file_info)

        if ferr != 0 {
            panic("stat failed")
        }
        if !file_info.is_dir {
            panic("not a directory")
        }
    }

    file_infos, _ := os.read_dir(d, -1)
    return file_infos
}

main :: proc() {
    f, _ := os.open("assets.odin", os.O_WRONLY | os.O_CREATE | os.O_TRUNC)
    defer os.close(f)

    fmt.fprintln(f, "package game")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "EmbedAssets :: #config(EmbedAssets, false)")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "Asset :: struct {")
    fmt.fprintln(f, "\tpath: string,")
    fmt.fprintln(f, "\tpath_hash: Hash,")
    fmt.fprintln(f, "\tdata: []u8,")
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    texture_paths := make([dynamic]string, context.temp_allocator)
    level_paths := make([dynamic]string, context.temp_allocator)
    font_paths := make([dynamic]string, context.temp_allocator)
    shader_paths := make([dynamic]string, context.temp_allocator)
    sound_paths := make([dynamic]string, context.temp_allocator)
    music_paths := make([dynamic]string, context.temp_allocator)

    // root folder files
    {
        file_infos := dir_path_to_file_infos(".")
        for fi in file_infos {
            if strings.has_suffix(fi.name, ".frag") {
                append(&shader_paths, fi.name)
            //} else if strings.has_suffix(fi.name, ".vert") {
                //append(&shader_paths, fi.name)
            }
        }
    }

    // Resources
    {
        file_infos := dir_path_to_file_infos("Resources")
        for fi in file_infos {
            if strings.has_suffix(fi.name, ".png") {
                append(&texture_paths, fmt.tprintf("Resources/%s", fi.name))
            } else if strings.has_suffix(fi.name, ".ldtk") {
                append(&level_paths, fmt.tprintf("Resources/%s", fi.name))
            }
        }
    }

    // Resources/Audio/Sound
    {
        file_infos := dir_path_to_file_infos("Resources/Audio/Sound")
        for fi in file_infos {
            if strings.has_suffix(fi.name, ".wav") {
                append(&sound_paths, fmt.tprintf("Resources/Audio/Sound/%s", fi.name))
            }
        }
    }

    // Resources/Audio/Music
    {
        file_infos := dir_path_to_file_infos("Resources/Audio/Music")
        for fi in file_infos {
            if strings.has_suffix(fi.name, ".wav") {
                append(&music_paths, fmt.tprintf("Resources/Audio/Music/%s", fi.name))
            }
        }
    }

    // Resources/Fonts
    {
        file_infos := dir_path_to_file_infos("Resources/Fonts")
        for fi in file_infos {
            if strings.has_suffix(fi.name, ".png") {
                append(&font_paths, fmt.tprintf("Resources/Fonts/%s", fi.name))
            //} else if strings.has_suffix(fi.name, ".otf") {
                //append(&font_paths, fmt.tprintf("Resouces/Fonts/%s", fi.name))
            }
        }
    }

    asset_name :: proc(path: string) -> string {
        return fmt.tprintf("%s", strings.to_upper_camel_case(slashpath.name(slashpath.base(path)), context.temp_allocator))
    }

    fmt.fprintln(f, "TextureName :: enum {")
    fmt.fprint(f, "\tNone,\n")
    for p in texture_paths {
        fmt.fprintf(f, "\t%s,\n", asset_name(p))
    }
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "FontName :: enum {")
    for p in font_paths {
        fmt.fprintf(f, "\t%s,\n", asset_name(p))
    }
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "ShaderName :: enum {")
    for p in shader_paths {
        fmt.fprintf(f, "\t%s,\n", asset_name(p))
    }
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "SoundName :: enum {")
    fmt.fprint(f, "\tNone,\n")
    for p in sound_paths {
        fmt.fprintf(f, "\t%s,\n", asset_name(p))
    }
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "MusicName :: enum {")
    fmt.fprint(f, "\tNone,\n")
    for p in music_paths {
        fmt.fprintf(f, "\t%s,\n", asset_name(p))
    }
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    fmt.fprintln(f, "LevelName :: enum {")
    fmt.fprint(f, "\tNone,\n")
    for p in level_paths {
        fmt.fprintf(f, "\t%s,\n", asset_name(p))
    }
    fmt.fprintln(f, "}")
    fmt.fprintln(f, "")

    emit_asset_list :: proc(f: os.Handle, list_name: string, type: string, paths: [dynamic]string, embed: bool, include_none: bool) {
        fmt.fprintf(f, "\t%s := [%s]Asset {{\n", list_name, type)

        if include_none {
            fmt.fprint(f, "\t\t.None = {},\n")
        }

        if embed {
            for p in paths {
                fmt.fprintf(f, "\t\t.%s = {{ path = \"%s\", path_hash = %v, data = #load(\"%s\"), }},\n", asset_name(p), p, hash.murmur64a(transmute([]byte)(p)), p)
            }
        } else {
            for p in paths {
                fmt.fprintf(f, "\t\t.%s = {{ path = \"%s\", path_hash = %v, },\n", asset_name(p), p, hash.murmur64a(transmute([]byte)(p)))
            }
        }
        fmt.fprintln(f, "\t}")
    }

    fmt.fprintln(f, "when EmbedAssets {")
    emit_asset_list(f, "all_textures", "TextureName", texture_paths, true, true)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_levels", "LevelName", level_paths, true, false)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_fonts", "FontName", font_paths, true, false)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_shaders", "ShaderName", shader_paths, true, false)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_sounds", "SoundName", sound_paths, true, true)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_music", "MusicName", music_paths, true, true)
    fmt.fprintln(f, "")
    fmt.fprintln(f, "} else {")
    emit_asset_list(f, "all_textures", "TextureName", texture_paths, false, true)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_levels", "LevelName", level_paths, false, false)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_fonts", "FontName", font_paths, false, false)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_shaders", "ShaderName", shader_paths, false, false)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_sounds", "SoundName", sound_paths, false, true)
    fmt.fprintln(f, "")
    emit_asset_list(f, "all_music", "MusicName", music_paths, false, true)
    fmt.fprintln(f, "")
    fmt.fprintln(f, "}")
}
