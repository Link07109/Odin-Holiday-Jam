package game

import rl "../../raylib"

Timer :: struct {
    // time in seconds
    lifetime: f32,
    started: bool,
}

timer_start :: proc (timer: ^Timer, lifetime: f32) {
    timer.lifetime = lifetime
    timer.started = true
}

timer_update :: proc (timer: ^Timer) {
    if timer.started && timer.lifetime > 0 {
        timer.lifetime -= rl.GetFrameTime()
    }
}

timer_done :: proc (timer: ^Timer) -> bool {
    if timer.started {
        check := timer.lifetime <= 0
        if check {
            timer.started = false
        }
        return check
    }
    return false
}
