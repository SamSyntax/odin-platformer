package main

import rl "vendor:raylib"

LEVEL_COUNT :: 3
LEVEL_TRANSITION_DELAY :: f32(2)

load_level :: proc(game: ^Game, index: u8) {
	game.platform_count = 0
	game.coin_count = 0
	game.door_count = 0
	game.score = 0
	game.player.vel = {}
	game.player.on_ground = false
	game.transition_timer = 0
	switch index {
	case 0:
		level_1(game)
	case 1:
		level_2(game)
	case 2:
		level_3(game)
	}
	game.player.spawn_pos = game.player.pos
}

add_platform :: proc(game: ^Game, x, y, w, h: f32, colour: rl.Color) {
	assert(game.platform_count < MAX_PLATFORMS, "too many platforms")
	game.platforms[game.platform_count] = Platform{{x, y, w, h}, colour}
	game.platform_count += 1
}

level_1 :: proc(game: ^Game) {}
level_2 :: proc(game: ^Game) {}
level_3 :: proc(game: ^Game) {}
