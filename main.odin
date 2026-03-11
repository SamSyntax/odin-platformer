package main

import rl "vendor:raylib"

WINDOW_HEIGHT :: 600
WINDOW_WIDTH :: 800
TARGET_FPS :: 60

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Platformer with Odin")
	defer rl.CloseWindow()
	rl.SetTargetFPS(TARGET_FPS)
	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		rl.BeginDrawing()
		rl.ClearBackground(rl.ORANGE)
		rl.EndDrawing()
	}
}
