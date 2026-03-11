package main

import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
PLAYER_COLOUR :: rl.Color{70, 130, 180, 255}

Player :: struct {
	vel:       rl.Vector2,
	pos:       rl.Vector2,
	size:      rl.Vector2,
	spawn_pos: rl.Vector2,
	on_ground: bool,
}

Game :: struct {
	player: Player,
}

game_init :: proc() -> Game {
	game: Game
	game.player.size = {28, 44}
	game.player.pos = {60, 460}
	game.player.spawn_pos = game.player.pos
	return game
}

game_draw :: proc(game: ^Game) {
	rl.ClearBackground({135, 206, 235, 255})
	draw_player(game.player)
}

player_rect :: proc(p: Player) -> rl.Rectangle {
	return {p.pos.x, p.pos.y, p.size.x, p.size.y}
}

draw_player :: proc(player: Player) {
	r := player_rect(player)
	rl.DrawRectangleRec(r, PLAYER_COLOUR)
	eye_y := i32(r.y) + 12
	left_x := i32(r.x) + 6
	right_x := i32(r.x) + 16
	rl.DrawCircle(left_x, eye_y, 5, rl.WHITE)
	rl.DrawCircle(right_x, eye_y, 5, rl.WHITE)
	rl.DrawCircle(left_x + 1, eye_y + 1, 2, rl.BLACK)
	rl.DrawCircle(right_x + 1, eye_y + 1, 2, rl.BLACK)
}
