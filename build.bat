@echo off

if not exist build mkdir build

set game_name=game.exe

pushd build
odin build ..\src\desktop -out:%game_name% -debug -vet -strict-style -define:EmbedAssets=true -subsystem=windows -no-bounds-check
ResourceHacker -open %game_name% -save %game_name% -action addskip -res ..\assets\icon.ico -mask ICONGROUP,MAINICON,
popd

@pause