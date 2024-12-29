package game

EmbedAssets :: #config(EmbedAssets, false)

Asset :: struct {
    path: string,
    path_hash: Hash,
    data: []u8,
}

TextureName :: enum {
    None,
    Icon,
    TitleScreen,
    Worldtiles,
}

FontName :: enum {
    Pixantiqua,
}

ShaderName :: enum {
    Acerola,
}

SoundName :: enum {
    None,
    Alert,
    BrainPierce,
    CollisionSound,
    Confused,
    DeathSwooosh,
    Gunshot,
    MenuButton,
    Random1,
    Random3,
    Random4,
    Random5,
    Random7,
    Random8,
    Randomize15,
    SwordSwoosh,
}

MusicName :: enum {
    None,
    Ascent,
    Battle,
    GameOver,
    Minigame,
}

LevelName :: enum {
    None,
    World,
}

when EmbedAssets {
    all_textures := [TextureName]Asset {
        .None = {},
        .Icon = { path = "Resources/icon.png", path_hash = 12509884978944795428, data = #load("Resources/icon.png"), },
        .TitleScreen = { path = "Resources/title_screen.png", path_hash = 8296462039691054324, data = #load("Resources/title_screen.png"), },
        .Worldtiles = { path = "Resources/worldtiles.png", path_hash = 2799477347926799472, data = #load("Resources/worldtiles.png"), },
    }

    all_levels := [LevelName]Asset {
        .None = {},
        .World = { path = "Resources/world.ldtk", path_hash = 856303520804203995, data = #load("Resources/world.ldtk"), },
    }

    all_fonts := [FontName]Asset {
        .Pixantiqua = { path = "Resources/Fonts/pixantiqua.png", path_hash = 4716181473603516022, data = #load("Resources/Fonts/pixantiqua.png"), },
    }

    all_shaders := [ShaderName]Asset {
        .Acerola = { path = "acerola.frag", path_hash = 17324121203074892642, data = #load("acerola.frag"), },
    }

    all_sounds := [SoundName]Asset {
        .None = {},
        .Alert = { path = "Resources/Audio/Sound/alert.wav", path_hash = 50295737133859763, data = #load("Resources/Audio/Sound/alert.wav"), },
        .BrainPierce = { path = "Resources/Audio/Sound/brain pierce.wav", path_hash = 9771330280218373084, data = #load("Resources/Audio/Sound/brain pierce.wav"), },
        .CollisionSound = { path = "Resources/Audio/Sound/collision_sound.wav", path_hash = 17535408556816024142, data = #load("Resources/Audio/Sound/collision_sound.wav"), },
        .Confused = { path = "Resources/Audio/Sound/confused.wav", path_hash = 4049994803537101712, data = #load("Resources/Audio/Sound/confused.wav"), },
        .DeathSwooosh = { path = "Resources/Audio/Sound/death swooosh.wav", path_hash = 8588506461413802837, data = #load("Resources/Audio/Sound/death swooosh.wav"), },
        .Gunshot = { path = "Resources/Audio/Sound/gunshot.wav", path_hash = 12781709074367880552, data = #load("Resources/Audio/Sound/gunshot.wav"), },
        .MenuButton = { path = "Resources/Audio/Sound/menu button.wav", path_hash = 11517319623079552837, data = #load("Resources/Audio/Sound/menu button.wav"), },
        .Random1 = { path = "Resources/Audio/Sound/random 1.wav", path_hash = 9346150716614757916, data = #load("Resources/Audio/Sound/random 1.wav"), },
        .Random3 = { path = "Resources/Audio/Sound/random 3.wav", path_hash = 14824557231224396075, data = #load("Resources/Audio/Sound/random 3.wav"), },
        .Random4 = { path = "Resources/Audio/Sound/random 4.wav", path_hash = 13742709765300141516, data = #load("Resources/Audio/Sound/random 4.wav"), },
        .Random5 = { path = "Resources/Audio/Sound/random 5.wav", path_hash = 12093904007733694997, data = #load("Resources/Audio/Sound/random 5.wav"), },
        .Random7 = { path = "Resources/Audio/Sound/random 7.wav", path_hash = 11044258967972765570, data = #load("Resources/Audio/Sound/random 7.wav"), },
        .Random8 = { path = "Resources/Audio/Sound/random 8.wav", path_hash = 16024152843079554374, data = #load("Resources/Audio/Sound/random 8.wav"), },
        .Randomize15 = { path = "Resources/Audio/Sound/Randomize15.wav", path_hash = 16989150221603834066, data = #load("Resources/Audio/Sound/Randomize15.wav"), },
        .SwordSwoosh = { path = "Resources/Audio/Sound/sword swoosh.wav", path_hash = 2169098366142651607, data = #load("Resources/Audio/Sound/sword swoosh.wav"), },
    }

    all_music := [MusicName]Asset {
        .None = {},
        .Ascent = { path = "Resources/Audio/Music/ascent.wav", path_hash = 14850104731728757001, data = #load("Resources/Audio/Music/ascent.wav"), },
        .Battle = { path = "Resources/Audio/Music/battle.wav", path_hash = 2288580337236489524, data = #load("Resources/Audio/Music/battle.wav"), },
        .GameOver = { path = "Resources/Audio/Music/game over.wav", path_hash = 1794120433551503374, data = #load("Resources/Audio/Music/game over.wav"), },
        .Minigame = { path = "Resources/Audio/Music/minigame.wav", path_hash = 4870693721296236436, data = #load("Resources/Audio/Music/minigame.wav"), },
    }

} else {
    all_textures := [TextureName]Asset {
        .None = {},
        .Icon = { path = "Resources/icon.png", path_hash = 12509884978944795428, },
        .TitleScreen = { path = "Resources/title_screen.png", path_hash = 8296462039691054324, },
        .Worldtiles = { path = "Resources/worldtiles.png", path_hash = 2799477347926799472, },
    }

    all_levels := [LevelName]Asset {
        .None = {},
        .World = { path = "Resources/world.ldtk", path_hash = 856303520804203995, },
    }

    all_fonts := [FontName]Asset {
        .Pixantiqua = { path = "Resources/Fonts/pixantiqua.png", path_hash = 4716181473603516022, },
    }

    all_shaders := [ShaderName]Asset {
        .Acerola = { path = "acerola.frag", path_hash = 17324121203074892642, },
    }

    all_sounds := [SoundName]Asset {
        .None = {},
        .Alert = { path = "Resources/Audio/Sound/alert.wav", path_hash = 50295737133859763, },
        .BrainPierce = { path = "Resources/Audio/Sound/brain pierce.wav", path_hash = 9771330280218373084, },
        .CollisionSound = { path = "Resources/Audio/Sound/collision_sound.wav", path_hash = 17535408556816024142, },
        .Confused = { path = "Resources/Audio/Sound/confused.wav", path_hash = 4049994803537101712, },
        .DeathSwooosh = { path = "Resources/Audio/Sound/death swooosh.wav", path_hash = 8588506461413802837, },
        .Gunshot = { path = "Resources/Audio/Sound/gunshot.wav", path_hash = 12781709074367880552, },
        .MenuButton = { path = "Resources/Audio/Sound/menu button.wav", path_hash = 11517319623079552837, },
        .Random1 = { path = "Resources/Audio/Sound/random 1.wav", path_hash = 9346150716614757916, },
        .Random3 = { path = "Resources/Audio/Sound/random 3.wav", path_hash = 14824557231224396075, },
        .Random4 = { path = "Resources/Audio/Sound/random 4.wav", path_hash = 13742709765300141516, },
        .Random5 = { path = "Resources/Audio/Sound/random 5.wav", path_hash = 12093904007733694997, },
        .Random7 = { path = "Resources/Audio/Sound/random 7.wav", path_hash = 11044258967972765570, },
        .Random8 = { path = "Resources/Audio/Sound/random 8.wav", path_hash = 16024152843079554374, },
        .Randomize15 = { path = "Resources/Audio/Sound/Randomize15.wav", path_hash = 16989150221603834066, },
        .SwordSwoosh = { path = "Resources/Audio/Sound/sword swoosh.wav", path_hash = 2169098366142651607, },
    }

    all_music := [MusicName]Asset {
        .None = {},
        .Ascent = { path = "Resources/Audio/Music/ascent.wav", path_hash = 14850104731728757001, },
        .Battle = { path = "Resources/Audio/Music/battle.wav", path_hash = 2288580337236489524, },
        .GameOver = { path = "Resources/Audio/Music/game over.wav", path_hash = 1794120433551503374, },
        .Minigame = { path = "Resources/Audio/Music/minigame.wav", path_hash = 4870693721296236436, },
    }

}
