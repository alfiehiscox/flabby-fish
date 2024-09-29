package main

import rl "vendor:raylib"

WIDTH :: 800
HEIGHT :: 550
GRAVITY :: 500

FISH_H_SPEED :: 200
FISH_JMP_SPEED :: 250

WALL_WIDTH :: 50
GAP_START :: 200
GAP_HEIGHT :: 100


Fish :: struct {
	pos:     rl.Vector2,
	size:    rl.Vector2,
	v_speed: f32,
	h_speed: f32,
}

WallSection :: struct {
	pos:     rl.Vector2,
	size:    rl.Vector2,
	v_speed: f32,
}

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "Flabby Fish")
	rl.SetTargetFPS(120)

	player := Fish {
		pos     = rl.Vector2{WIDTH / 3, WIDTH / 3},
		size    = rl.Vector2{20, 20},
		v_speed = 0,
		h_speed = FISH_H_SPEED,
	}

	wall := []WallSection {
		WallSection {
			pos = rl.Vector2{WIDTH + 200, 0},
			size = rl.Vector2{WALL_WIDTH, GAP_START},
			v_speed = 200,
		},
		WallSection {
			pos = rl.Vector2{WIDTH + 200, GAP_START + GAP_HEIGHT},
			size = rl.Vector2{WALL_WIDTH, HEIGHT - (GAP_START + GAP_HEIGHT)},
			v_speed = 200,
		},
	}

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		// Update
		updateFish(&player, delta)
		updateWall(wall, delta)

		// Draw
		rl.BeginDrawing();defer rl.EndDrawing()
		rl.ClearBackground(rl.WHITE)

		rl.DrawRectangleV(player.pos, player.size, rl.BLACK)

		for w in wall {
			rl.DrawRectangleV(w.pos, w.size, rl.BLACK)
		}
	}

	rl.CloseWindow()
}

updateFish :: proc(fish: ^Fish, delta: f32) {

	fish.pos.y += fish.v_speed * delta
	fish.v_speed += GRAVITY * delta

	if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
		fish.v_speed = -FISH_JMP_SPEED
	}
}

updateWall :: proc(wall: []WallSection, delta: f32) {
	for &w in wall {
		w.pos.x -= w.v_speed * delta
	}
}
