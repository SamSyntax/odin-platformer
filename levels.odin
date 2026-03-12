package main

import rl "vendor:raylib"

LEVEL_COUNT :: 3
LEVEL_TRANSITION_DELAY :: f32(1.5)

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

add_coin :: proc(game: ^Game, x, y: f32) {
	assert(game.coin_count < MAX_COINS, "too many coins")
	game.coins[game.coin_count] = Coin {
		pos = {x, y},
	}
	game.coin_count += 1
}

add_door :: proc(game: ^Game, x, y, w, h: f32, coins_required: u8) {
	assert(game.door_count < MAX_DOORS, "too many doors")
	game.doors[game.door_count] = Door {
		rect           = {x, y, w, h},
		open           = false,
		coins_required = coins_required,
	}
  game.door_count += 1
}

level_1 :: proc(game: ^Game) {
	game.player.pos = {60, 460}
	add_platform(game, 0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 40, rl.DARKGREEN)
	add_platform(game, 100, 460, 140, 16, rl.BROWN)
	add_platform(game, 300, 390, 140, 16, rl.BROWN)
	add_platform(game, 500, 320, 140, 16, rl.BROWN)
	add_platform(game, 200, 240, 140, 16, rl.BROWN)
	add_platform(game, 580, 200, 100, 16, rl.BROWN)
	add_platform(game, 50, 150, 120, 16, rl.MAROON)

	add_coin(game, 400, 525)
	add_coin(game, 170, 430)
	add_coin(game, 250, 410)
	add_coin(game, 370, 360)
	add_coin(game, 570, 290)
	add_coin(game, 270, 210)
	add_coin(game, 630, 170)
	add_coin(game, 110, 120)

	add_door(game, 453, 195, 20, 365, 4)
}
level_2 :: proc(game: ^Game) {
	game.player.pos = {SCREEN_WIDTH - 100, 500}

	add_platform(game, 0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 40, rl.DARKGRAY)

	add_platform(game, 500, 480, 120, 16, rl.GRAY)
	add_platform(game, 300, 400, 120, 16, rl.GRAY)
	add_platform(game, 500, 320, 100, 16, rl.GRAY)
	add_platform(game, 300, 240, 100, 16, rl.GRAY)
	add_platform(game, 100, 180, 100, 16, rl.GRAY)

	add_platform(game, 350, 100, 150, 16, rl.GOLD)

	add_coin(game, 350, 450)
	add_coin(game, 550, 370)
	add_coin(game, 350, 290)
	add_coin(game, 150, 220)
	add_coin(game, 400, 70)
	add_coin(game, 450, 70)

	add_door(game, 460, 65, 20, 30, 4)
}
level_3 :: proc(game: ^Game) {
	game.player.pos = {40, 520}

	add_platform(game, 0, 560, 100, 40, rl.DARKBLUE)

	add_platform(game, 220, 480, 80, 16, rl.BLUE)
	add_platform(game, 450, 480, 80, 16, rl.BLUE)

	add_platform(game, 650, 400, 60, 16, rl.PURPLE)

	add_platform(game, 400, 300, 120, 16, rl.BLUE)
	add_platform(game, 150, 250, 100, 16, rl.BLUE)

	add_platform(game, 380, 150, 40, 16, rl.VIOLET)

	add_coin(game, 260, 440)
	add_coin(game, 490, 440)
	add_coin(game, 680, 360)
	add_coin(game, 400, 110) // Coin above the tiny platform

	add_door(game, 20, 215, 20, 30, 3)
}
