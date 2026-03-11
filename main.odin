package main

import rl "vendor:raylib"

WINDOW_HEIGHT :: 1200
WINDOW_WIDTH :: 1600
TARGET_FPS :: 60

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Platformer with Odin")
	defer rl.CloseWindow()
	rl.SetTargetFPS(TARGET_FPS)
  game := game_init()
	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		rl.BeginDrawing()
    game_draw(&game)
		rl.EndDrawing()
	}
}
