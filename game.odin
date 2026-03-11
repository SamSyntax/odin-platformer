package main

import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

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
