package game

EmbedAssets :: #config(EmbedAssets, false)

Asset :: struct {
    path: string,
    path_hash: Hash,
    data: []u8,
}

TextureName :: enum {
    None,
    Worldtiles,
}

FontName :: enum {
}

ShaderName :: enum {
}

SoundName :: enum {
    None,
}

MusicName :: enum {
    None,
}

LevelName :: enum {
    None,
    World,
}

when EmbedAssets {
    all_textures := [TextureName]Asset {
        .None = {},
        .Worldtiles = { path = "Resources/worldtiles.png", path_hash = 2799477347926799472, data = #load("Resources/worldtiles.png"), },
    }

    all_levels := [LevelName]Asset {
        .None = {},
        .World = { path = "Resources/world.ldtk", path_hash = 856303520804203995, data = #load("Resources/world.ldtk"), },
    }

    all_fonts := [FontName]Asset {
    }

    all_shaders := [ShaderName]Asset {
    }

    all_sounds := [SoundName]Asset {
        .None = {},
    }

    all_music := [MusicName]Asset {
        .None = {},
    }

} else {
    all_textures := [TextureName]Asset {
        .None = {},
        .Worldtiles = { path = "Resources/worldtiles.png", path_hash = 2799477347926799472, },
    }

    all_levels := [LevelName]Asset {
        .None = {},
        .World = { path = "Resources/world.ldtk", path_hash = 856303520804203995, },
    }

    all_fonts := [FontName]Asset {
    }

    all_shaders := [ShaderName]Asset {
    }

    all_sounds := [SoundName]Asset {
        .None = {},
    }

    all_music := [MusicName]Asset {
        .None = {},
    }

}
