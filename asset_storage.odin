package game

import rl "vendor:raylib"
import "ldtk"
import "core:math/rand"
import "core:strings"
import "core:os"
import "core:fmt"
import "core:slice"
import core_hash "core:hash"

_ :: fmt

Hash :: distinct u64

hash :: proc(s: string) -> Hash {
    return Hash(core_hash.murmur64a(transmute([]byte)(s)))
}

temp_cstring :: proc(s:string) -> cstring {
    return strings.clone_to_cstring(s, context.temp_allocator)
}

load_image :: proc(name: TextureName) -> rl.Image {
    ta := all_textures[name]

    when EmbedAssets {
        return rl.LoadImageFromMemory(".png", &ta.data[0], i32(len(ta.data)))
    } else {
        return rl.LoadImage(temp_cstring(ta.path))
    } 
}

load_texture_from_mem :: proc(name: TextureName, data: []u8) -> rl.Texture {
    img := load_image(name)
    tex := rl.LoadTextureFromImage(img)
    rl.UnloadImage(img)
    return tex
}

load_texture :: proc(name: TextureName) -> rl.Texture {
    ta := all_textures[name]
    t: rl.Texture

    when EmbedAssets {
        t = load_texture_from_mem(name, ta.data)
    } else {
        t = rl.LoadTexture(temp_cstring(ta.path))
    }

    return t
}

load_level_data :: proc(l: LevelName) -> Maybe(ldtk.Project) {
    level := all_levels[l]

    when EmbedAssets {
        return ldtk.load_from_memory(level.data, context.temp_allocator)
    } else {
       return ldtk.load_from_file(level.path, context.temp_allocator)
    }
}

load_font_image_from_mem :: proc(file_data: rawptr) -> rl.Font {
    img := rl.LoadImageFromMemory(".png", file_data, 128*128)
    font := rl.LoadFontFromImage(img, rl.Color { 255, 0, 255, 255 }, ' ')
    rl.UnloadImage(img)
    return font
}

load_font :: proc(name: FontName, font_size: int = 0) -> rl.Font {
    fa := all_fonts[name]
    f: rl.Font

    when EmbedAssets {
        f = load_font_image_from_mem(&fa.data[0])
    } else {
        f = rl.LoadFont(temp_cstring(fa.path))
    }

    return f
}

load_shader :: proc(name: ShaderName) -> rl.Shader {
    s := all_shaders[name]

    when EmbedAssets {
        d := strings.string_from_ptr(&s.data[0], len(s.data))
        return rl.LoadShaderFromMemory(nil, temp_cstring(d))
    } else {
        return rl.LoadShader(nil, temp_cstring(s.path))
    } 
}

load_sound :: proc(name: SoundName) -> rl.Sound {
    s := all_sounds[name]

    when EmbedAssets {
        w := rl.LoadWaveFromMemory(".wav", &s.data[0], i32(len(s.data)))
        snd := rl.LoadSoundFromWave(w)
        rl.UnloadWave(w)
        return snd
    } else {
        return rl.LoadSound(temp_cstring(s.path))
    } 
}

load_music :: proc(name: MusicName) -> rl.Music {
    s := all_music[name]

    when EmbedAssets {
        return rl.LoadMusicStreamFromMemory(".wav", &s.data[0], i32(len(s.data)))
    } else {
        return rl.LoadMusicStream(temp_cstring(s.path))
    } 
}
