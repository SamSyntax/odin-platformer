package main

import "core:fmt"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
PLAYER_COLOUR :: rl.Color{70, 130, 180, 255}
GRAVITY :: f32(1200)
JUMP_VELOCITY :: f32(-560)
MOVE_SPEED :: f32(280)
MAX_FALL_SPEED :: f32(800)
MAX_PLATFORMS :: 16

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
	player:         Player,
	platforms:      [MAX_PLATFORMS]Platform,
	platform_count: i8,
}

draw_framerate :: proc() {
  rl.DrawText(fmt.ctprintf("%d", rl.GetFPS()), 10, 10, 20, rl.BLACK)
}

game_init :: proc() -> Game {
	game: Game
	game.player.size = {28, 44}
	game.player.pos = {60, 460}
	game.player.spawn_pos = game.player.pos
  game.player.direction = .LEFT

	game.platforms[0] = Platform {
		rect  = {0, 560, 800, 40},
		color = rl.DARKGREEN,
	}
	game.platforms[1] = Platform {
		rect  = {100, 460, 140, 16},
		color = rl.BROWN,
	}
	game.platforms[2] = Platform {
		rect  = {240, 260, 330, 24},
		color = rl.BROWN,
	}
	game.platform_count = 3

	return game
}

game_update :: proc(game: ^Game, dt: f32) {
	platforms := game.platforms[:game.platform_count]
	player_update(&game.player, platforms, dt)
  draw_framerate()
}

player_update :: proc(player: ^Player, platforms: []Platform, dt: f32) {
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
	for p in platforms {
		resolve_horizontal(player, p.rect)
	}
	player.pos.x = clamp(player.pos.x, 0, f32(SCREEN_WIDTH) - player.size.x)

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
	draw_player(game.player)
}

draw_platforms :: proc(platforms: []Platform) {
	for p in platforms {
		rl.DrawRectangleRec(p.rect, p.color)
		rl.DrawRectangle(i32(p.rect.x), i32(p.rect.y), i32(p.rect.width), 4, {255, 255, 255, 80})
	}
}

player_rect :: proc(p: Player) -> rl.Rectangle {
	return {p.pos.x, p.pos.y, p.size.x, p.size.y,}
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
