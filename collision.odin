package main

import rl "vendor:raylib"

resolve_horizontal :: proc(player: ^Player, rect: rl.Rectangle) {
	pr := player_rect(player^)
	if !rl.CheckCollisionRecs(pr, rect) do return
	if pr.x < rect.x {
		player.pos.x = rect.x - pr.width
	} else {
		player.pos.x = rect.x + rect.width
	}

	player.vel.x = 0
}

resolve_vertical :: proc(player: ^Player, rect: rl.Rectangle) {
	pr := player_rect(player^)
	if !rl.CheckCollisionRecs(pr, rect) do return
	if pr.y < rect.y {
		player.pos.y = rect.y - pr.height
		player.vel.y = 0
		player.on_ground = true
	} else {
		player.pos.y = rect.y + rect.height
    player.vel.y = 0
	}

}
