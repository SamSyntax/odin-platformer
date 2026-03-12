package main

import "core:fmt"
import rl "vendor:raylib"

foreign import "raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
COIN_RADIUS :: f32(8)

GRAVITY :: f32(1200)
JUMP_VELOCITY :: f32(-560)
MOVE_SPEED :: f32(280)

PLAYER_COLOUR :: rl.Color{70, 130, 180, 255}
COIN_COLOUR :: rl.Color{255, 215, 0, 255}
COIN_DEPTH_OUTLINE_COLOUR :: rl.Color{255, 178, 13, 255}

MAX_FALL_SPEED :: f32(800)
MAX_PLATFORMS :: 16
MAX_COINS :: 32
MAX_DOORS :: 8


Platform :: struct {
	rect:  rl.Rectangle,
	color: rl.Color,
}

Direction :: enum u8 {
	LEFT,
	RIGHT,
}

Player :: struct {
	vel:       rl.Vector2,
	pos:       rl.Vector2,
	size:      rl.Vector2,
	spawn_pos: rl.Vector2,
	direction: Direction,
	on_ground: bool,
}

Game :: struct {
	player:           Player,
	platforms:        [MAX_PLATFORMS]Platform,
	platform_count:   u8,
	coins:            [MAX_COINS]Coin,
	coin_count:       u16,
	total_score:      u16,
	score:            u8,
	doors:            [MAX_DOORS]Door,
	door_count:       u8,
	current_level:    u8,
	game_complete:    bool,
	transition_timer: f32,
}

Coin :: struct {
	pos:       rl.Vector2,
	collected: bool,
}


Door :: struct {
	rect:           rl.Rectangle,
	open:           bool,
	coins_required: u8,
}


game_init :: proc() -> Game {
	game: Game
	game.player.size = {28, 44}
	load_level(&game, 0)
	return game
}

game_update :: proc(game: ^Game, dt: f32) {
	if (game.game_complete) do return
	if game.transition_timer > 0 {
		game.transition_timer -= dt
		if game.transition_timer <= 0 {
			next := game.current_level + 1
			if next < LEVEL_COUNT {
				game.current_level = next
				load_level(game, next)
			} else {
				game.game_complete = true
			}
		}
		return
	}
	platforms := game.platforms[:game.platform_count]
	doors := game.doors[:game.door_count]
	player_update(&game.player, platforms, doors, dt)
	coins_collect(game)
	draw_doors(game.doors[:game.door_count])
	draw_hud(game^)
	if (game.total_score == game.coin_count && game.coin_count > 0) {
		game.transition_timer = LEVEL_TRANSITION_DELAY
	}
}


player_update :: proc(player: ^Player, platforms: []Platform, doors: []Door, dt: f32) {
	player.vel.x = 0

	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		player.vel.x = -MOVE_SPEED
		player.direction = .LEFT
	}
	if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		player.vel.x = MOVE_SPEED
		player.direction = .RIGHT
	}

	jump_pressed := rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W)
	if jump_pressed && player.on_ground {
		player.vel.y = JUMP_VELOCITY
		player.on_ground = false
	}

	// accumulate gravity each frame
	player.vel.y = min(player.vel.y + GRAVITY * dt, MAX_FALL_SPEED)
	player.pos.x += player.vel.x * dt
	for d in doors {
		if !d.open {
			resolve_horizontal(player, d.rect)
		}
	}
	for p in platforms {
		resolve_horizontal(player, p.rect)
	}
	player.pos.x = clamp(player.pos.x, 0, f32(WINDOW_WIDTH) - player.size.x)

	player.on_ground = false
	player.pos.y += player.vel.y * dt
	for p in platforms {
		resolve_vertical(player, p.rect)
	}

	if player.pos.y > f32(SCREEN_WIDTH) + 200 {
		player.pos = player.spawn_pos
		player.vel = {}
	}
}

game_draw :: proc(game: ^Game) {
	rl.ClearBackground({135, 206, 235, 255})
	draw_platforms(game.platforms[:game.platform_count])
	draw_doors(game.doors[:game.door_count])
	draw_player(game.player)
	draw_coins(game.coins[:game.coin_count])
	draw_hud(game^)
	game_overlay(game^)
}

draw_platforms :: proc(platforms: []Platform) {
	for p in platforms {
		rl.DrawRectangleRec(p.rect, p.color)
		rl.DrawRectangle(i32(p.rect.x), i32(p.rect.y), i32(p.rect.width), 4, {255, 255, 255, 80})
	}
}

player_rect :: proc(p: Player) -> rl.Rectangle {
	return {p.pos.x, p.pos.y, p.size.x, p.size.y}
}

draw_player :: proc(player: Player) {
	r := player_rect(player)
	rl.DrawRectangleRec(r, PLAYER_COLOUR)
	eye_y := i32(r.y) + 12
	left_x := i32(r.x)
	right_x := i32(r.x)
	switch player.direction {
	case .LEFT:
		left_x = i32(r.x) + 6
		right_x = i32(r.x) + 16
	case .RIGHT:
		left_x = i32(r.x) + 12
		right_x = i32(r.x) + 22
	}
	rl.DrawCircle(left_x, eye_y, 5, rl.WHITE)
	rl.DrawCircle(right_x, eye_y, 5, rl.WHITE)
	rl.DrawCircle(left_x + 1, eye_y + 1, 2, rl.BLACK)
	rl.DrawCircle(right_x + 1, eye_y + 1, 2, rl.BLACK)
}

coin_rect :: proc(coin: Coin) -> rl.Rectangle {
	return {coin.pos.x, coin.pos.y, COIN_RADIUS * 2, COIN_RADIUS * 2}
}

draw_coins :: proc(coins: []Coin) {
	for coin in coins {
		if !coin.collected {
			rl.DrawCircleLinesV(coin.pos, COIN_RADIUS, COIN_DEPTH_OUTLINE_COLOUR)
			rl.DrawCircle(i32(coin.pos.x), i32(coin.pos.y), COIN_RADIUS + 4, rl.BLACK)
			rl.DrawCircle(
				i32(coin.pos.x),
				i32(coin.pos.y),
				COIN_RADIUS + 2,
				COIN_DEPTH_OUTLINE_COLOUR,
			)
			rl.DrawCircle(i32(coin.pos.x), i32(coin.pos.y), COIN_RADIUS, COIN_COLOUR)
		}
	}
}


coins_collect :: proc(game: ^Game) {
	pr := player_rect(game.player)
	for &coin in game.coins[:game.coin_count] {
		if coin.collected do continue
		if rl.CheckCollisionCircleRec(coin.pos, COIN_RADIUS, pr) {
			coin.collected = true
			game.total_score += 1
			game.score += 1

		}
	}
	check_door(game^, game.doors[:game.door_count])
}


draw_doors :: proc(doors: []Door) {
	for d in doors {
		if d.open do continue
		if !d.open {
			rl.DrawRectangleRec(d.rect, rl.BROWN)
			rl.DrawRectangle(
				i32(d.rect.x),
				i32(d.rect.y),
				3,
				i32(d.rect.height),
				{255, 255, 255, 60},
			)

			icon_x := d.rect.x + d.rect.width / 2
			icon_y := d.rect.y - 24
			rl.DrawCircleV({icon_x, icon_y}, 8, COIN_COLOUR)
			rl.DrawCircleLinesV({icon_x, icon_y}, 8, COIN_DEPTH_OUTLINE_COLOUR)
			label := fmt.ctprintf("x%d", d.coins_required)
			label_w := rl.MeasureText(label, 16)
			rl.DrawText(label, i32(icon_x) - label_w / 2, i32(icon_y) + 12, 16, rl.BLACK)
		}
	}
}

check_door :: proc(game: Game, door: []Door) {
	collected: u8
	for c in game.coins {
		if c.collected {
			collected += 1
		}
	}
	for &d in door {
		if collected >= d.coins_required {
			d.open = true
		}
	}
}


draw_hud :: proc(game: Game) {
	level_str := fmt.ctprintf("Level %d / %d", game.current_level + 1, LEVEL_COUNT)
	level_w := rl.MeasureText(level_str, 16)
	rl.DrawText(level_str, SCREEN_WIDTH - level_w - 10, 10, 20, rl.BLACK)

	score_str := fmt.ctprintf("Coins: %d / %d", game.score, game.coin_count)
	score_w := rl.MeasureText(score_str, 16)
	rl.DrawText(score_str, SCREEN_WIDTH - score_w - 10, 30, 20, rl.BLACK)
}
game_overlay :: proc(game: Game) {}
