package main_desktop

import rl "../../raylib"
import "../game"

main :: proc() {
    game.init()
    defer game.fini()

    for !rl.WindowShouldClose() {
        game.frame()
    }
}
