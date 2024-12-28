/**
  * Modified version of Karl Zylinski's 
  * code from his game CAT & ONION
  */

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

load_ttf_from_memory :: proc(file_data: []byte, font_size: int) -> rl.Font {
    font := rl.Font {
        baseSize = i32(font_size),
        glyphCount = 95,
    }

    font.glyphs = rl.LoadFontData(&file_data[0], i32(len(file_data)), font.baseSize, {}, font.glyphCount, .DEFAULT)

    if font.glyphs != nil {
        font.glyphPadding = 4

        atlas := rl.GenImageFontAtlas(font.glyphs, &font.recs, font.glyphCount, font.baseSize, font.glyphPadding, 0)
        atlas_u8 := slice.from_ptr((^u8)(atlas.data), int(atlas.width*atlas.height*2))

        for i in 0..<atlas.width*atlas.height {
            a := atlas_u8[i*2 + 1]
            v := atlas_u8[i*2]
            atlas_u8[i*2] = u8(f32(v)*(f32(a)/255))
        }

        font.texture = rl.LoadTextureFromImage(atlas)
        rl.SetTextureFilter(font.texture, .BILINEAR)

        // Update glyphs[i].image to use alpha, required to be used on ImageDrawText()
        for i in 0..<font.glyphCount {
            rl.UnloadImage(font.glyphs[i].image)
            font.glyphs[i].image = rl.ImageFromImage(atlas, font.recs[i])
        }
        //TRACELOG(LOG_INFO, "FONT: Data loaded successfully (%i pixel size | %i glyphs)", font.baseSize, font.glyphCount);

        rl.UnloadImage(atlas)
    } else {
        font = rl.GetFontDefault()
    }

    return font
}

load_font_ttf :: proc(name: FontName, font_size: int = 0) -> rl.Font {
    fa := all_fonts[name]
    f: rl.Font

    when EmbedAssets {
        f = load_ttf_from_memory(fa.data, font_size)
    } else {
        if font_data, ok := os.read_entire_file(fa.path, context.temp_allocator); ok {
            f = load_ttf_from_memory(font_data, font_size)
        } else {
            f = rl.GetFontDefault()
        }
    }

    return f
}

font_key_color := rl.Color { 255, 0, 0, 0 }
load_font_image_from_mem :: proc(file_data: rawptr) -> rl.Font {
    img := rl.LoadImageFromMemory(".png", file_data, 128*128)
    font := rl.LoadFontFromImage(img, font_key_color, ' ')
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
