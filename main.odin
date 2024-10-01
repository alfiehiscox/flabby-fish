package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

WIDTH :: 576
HEIGHT :: 512
GRAVITY :: 500

FISH_H_SPEED :: 200
FISH_JMP_SPEED :: 250

WALL_WIDTH :: 50
GAP_START :: 200
GAP_HEIGHT :: 100
SPAWN_INTERVAL :: 3


Fish :: struct {
	pos:      rl.Vector2,
	size:     rl.Vector2,
	rotation: f32,
	v_speed:  f32,
	h_speed:  f32,
}

WallSection :: struct {
	pos:     rl.Vector2,
	size:    rl.Vector2,
	v_speed: f32,
}

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "Flabby Fish")
	defer rl.CloseWindow()

	rl.SetTargetFPS(120)

	background := rl.LoadTexture("resources/background-day.png")
	defer rl.UnloadTexture(background)
	background_scroll: f32 = 0

	player := Fish {
		pos      = rl.Vector2{WIDTH / 3, WIDTH / 3},
		size     = rl.Vector2{20, 20},
		rotation = 0,
		v_speed  = 0,
		h_speed  = FISH_H_SPEED,
	}

	walls := make([dynamic]WallSection, 0, 6)
	defer delete(walls)

	initWalls(&walls)

	spawn: f32 = SPAWN_INTERVAL

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		// Update
		updateFish(&player, delta)
		updateWalls(&walls, delta)

		background_scroll -= 0.1
		if background_scroll <= -f32(background.width) * 2 do background_scroll = 0

		if spawn <= 0 {
			spawn = SPAWN_INTERVAL
			append_wall(&walls, 200)
		} else {
			spawn -= delta
		}

		// Draw
		rl.BeginDrawing();defer rl.EndDrawing()
		rl.ClearBackground(rl.WHITE)

		rl.DrawTextureEx(background, rl.Vector2{background_scroll, 0}, 0, 1.0, rl.WHITE)
		rl.DrawTextureEx(
			background,
			rl.Vector2{f32(background.width) + background_scroll, 0},
			0,
			1.0,
			rl.WHITE,
		)
		rl.DrawTextureEx(
			background,
			rl.Vector2{f32(background.width * 2) + background_scroll, 0},
			0,
			1.0,
			rl.WHITE,
		)

		// rl.DrawRectangleV(player.pos, player.size, rl.BLACK)
		rl.DrawRectanglePro(
			rl.Rectangle {
				x = player.pos.x,
				y = player.pos.y,
				width = player.size.x,
				height = player.size.y,
			},
			rl.Vector2{player.size.x / 2, player.size.y / 2},
			player.rotation,
			rl.BLACK,
		)

		for w in walls {
			rl.DrawRectangleV(w.pos, w.size, rl.BLACK)
		}
	}

}

updateFish :: proc(fish: ^Fish, delta: f32) {
	fish.pos.y += fish.v_speed * delta
	fish.v_speed += GRAVITY * delta

	if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
		fish.v_speed = -FISH_JMP_SPEED
	}
}

updateWalls :: proc(walls: ^[dynamic]WallSection, delta: f32) {
	for &w, index in walls {
		if w.pos.x + WALL_WIDTH < 0 {
			ordered_remove(walls, index)
		} else {
			w.pos.x -= w.v_speed * delta
		}
	}
}

append_wall :: proc(walls: ^[dynamic]WallSection, gap_start: f32) {
	append(
		walls,
		WallSection {
			pos = rl.Vector2{WIDTH + 200, 0},
			size = rl.Vector2{WALL_WIDTH, gap_start},
			v_speed = 200,
		},
	)
	append(
		walls,
		WallSection {
			pos = rl.Vector2{WIDTH + 200, gap_start + GAP_HEIGHT},
			size = rl.Vector2{WALL_WIDTH, HEIGHT - (gap_start + GAP_HEIGHT)},
			v_speed = 200,
		},
	)
}

initWalls :: proc(walls: ^[dynamic]WallSection) {
	for wall, index in 0 ..< 3 {
		append(
			walls,
			WallSection {
				pos = rl.Vector2{f32(WIDTH + (index + 1) * 100), 0},
				size = rl.Vector2{WALL_WIDTH, 200},
				v_speed = 200,
			},
		)
		append(
			walls,
			WallSection {
				pos = rl.Vector2{f32(WIDTH + (index + 1) * 100), 200 + GAP_HEIGHT},
				size = rl.Vector2{WALL_WIDTH, HEIGHT - (200 + GAP_HEIGHT)},
				v_speed = 200,
			},
		)
	}
}
