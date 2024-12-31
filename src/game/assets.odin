package game

EmbedAssets :: #config(EmbedAssets, false)

Asset :: struct {
	path: string,
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
		.Icon = { path = "../../assets/icon.png", data = #load("../../assets/icon.png"), },
		.TitleScreen = { path = "../../assets/title_screen.png", data = #load("../../assets/title_screen.png"), },
		.Worldtiles = { path = "../../assets/worldtiles.png", data = #load("../../assets/worldtiles.png"), },
	}

	all_levels := [LevelName]Asset {
		.None = {},
		.World = { path = "../../assets/world.ldtk", data = #load("../../assets/world.ldtk"), },
	}

	all_fonts := [FontName]Asset {
		.Pixantiqua = { path = "../../assets/Fonts/pixantiqua.png", data = #load("../../assets/Fonts/pixantiqua.png"), },
	}

	all_shaders := [ShaderName]Asset {
	}

	all_sounds := [SoundName]Asset {
		.None = {},
		.Alert = { path = "../../assets/Audio/Sound/alert.wav", data = #load("../../assets/Audio/Sound/alert.wav"), },
		.BrainPierce = { path = "../../assets/Audio/Sound/brain pierce.wav", data = #load("../../assets/Audio/Sound/brain pierce.wav"), },
		.CollisionSound = { path = "../../assets/Audio/Sound/collision_sound.wav", data = #load("../../assets/Audio/Sound/collision_sound.wav"), },
		.Confused = { path = "../../assets/Audio/Sound/confused.wav", data = #load("../../assets/Audio/Sound/confused.wav"), },
		.DeathSwooosh = { path = "../../assets/Audio/Sound/death swooosh.wav", data = #load("../../assets/Audio/Sound/death swooosh.wav"), },
		.Gunshot = { path = "../../assets/Audio/Sound/gunshot.wav", data = #load("../../assets/Audio/Sound/gunshot.wav"), },
		.MenuButton = { path = "../../assets/Audio/Sound/menu button.wav", data = #load("../../assets/Audio/Sound/menu button.wav"), },
		.Random1 = { path = "../../assets/Audio/Sound/random 1.wav", data = #load("../../assets/Audio/Sound/random 1.wav"), },
		.Random3 = { path = "../../assets/Audio/Sound/random 3.wav", data = #load("../../assets/Audio/Sound/random 3.wav"), },
		.Random4 = { path = "../../assets/Audio/Sound/random 4.wav", data = #load("../../assets/Audio/Sound/random 4.wav"), },
		.Random5 = { path = "../../assets/Audio/Sound/random 5.wav", data = #load("../../assets/Audio/Sound/random 5.wav"), },
		.Random7 = { path = "../../assets/Audio/Sound/random 7.wav", data = #load("../../assets/Audio/Sound/random 7.wav"), },
		.Random8 = { path = "../../assets/Audio/Sound/random 8.wav", data = #load("../../assets/Audio/Sound/random 8.wav"), },
		.Randomize15 = { path = "../../assets/Audio/Sound/Randomize15.wav", data = #load("../../assets/Audio/Sound/Randomize15.wav"), },
		.SwordSwoosh = { path = "../../assets/Audio/Sound/sword swoosh.wav", data = #load("../../assets/Audio/Sound/sword swoosh.wav"), },
	}

	all_music := [MusicName]Asset {
		.None = {},
		.Ascent = { path = "../../assets/Audio/Music/ascent.wav", data = #load("../../assets/Audio/Music/ascent.wav"), },
		.Battle = { path = "../../assets/Audio/Music/battle.wav", data = #load("../../assets/Audio/Music/battle.wav"), },
		.GameOver = { path = "../../assets/Audio/Music/game over.wav", data = #load("../../assets/Audio/Music/game over.wav"), },
		.Minigame = { path = "../../assets/Audio/Music/minigame.wav", data = #load("../../assets/Audio/Music/minigame.wav"), },
	}

} else {
	all_textures := [TextureName]Asset {
		.None = {},
		.Icon = { path = "../../assets/icon.png" },
		.TitleScreen = { path = "../../assets/title_screen.png" },
		.Worldtiles = { path = "../../assets/worldtiles.png" },
	}

	all_levels := [LevelName]Asset {
		.None = {},
		.World = { path = "../../assets/world.ldtk" },
	}

	all_fonts := [FontName]Asset {
		.Pixantiqua = { path = "../../assets/Fonts/pixantiqua.png" },
	}

	all_shaders := [ShaderName]Asset {
	}

	all_sounds := [SoundName]Asset {
		.None = {},
		.Alert = { path = "../../assets/Audio/Sound/alert.wav" },
		.BrainPierce = { path = "../../assets/Audio/Sound/brain pierce.wav" },
		.CollisionSound = { path = "../../assets/Audio/Sound/collision_sound.wav" },
		.Confused = { path = "../../assets/Audio/Sound/confused.wav" },
		.DeathSwooosh = { path = "../../assets/Audio/Sound/death swooosh.wav" },
		.Gunshot = { path = "../../assets/Audio/Sound/gunshot.wav" },
		.MenuButton = { path = "../../assets/Audio/Sound/menu button.wav" },
		.Random1 = { path = "../../assets/Audio/Sound/random 1.wav" },
		.Random3 = { path = "../../assets/Audio/Sound/random 3.wav" },
		.Random4 = { path = "../../assets/Audio/Sound/random 4.wav" },
		.Random5 = { path = "../../assets/Audio/Sound/random 5.wav" },
		.Random7 = { path = "../../assets/Audio/Sound/random 7.wav" },
		.Random8 = { path = "../../assets/Audio/Sound/random 8.wav" },
		.Randomize15 = { path = "../../assets/Audio/Sound/Randomize15.wav" },
		.SwordSwoosh = { path = "../../assets/Audio/Sound/sword swoosh.wav" },
	}

	all_music := [MusicName]Asset {
		.None = {},
		.Ascent = { path = "../../assets/Audio/Music/ascent.wav" },
		.Battle = { path = "../../assets/Audio/Music/battle.wav" },
		.GameOver = { path = "../../assets/Audio/Music/game over.wav" },
		.Minigame = { path = "../../assets/Audio/Music/minigame.wav" },
	}

}
