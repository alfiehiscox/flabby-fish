package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

WIDTH :: 576
HEIGHT :: 512
GRAVITY :: 500

FISH_H_SPEED :: 200
FISH_JMP_SPEED :: 250

TOTAL_WALLS :: 3
WALL_WIDTH :: 56
WALL_GAP :: 200

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

	player_texture := rl.LoadTexture("resources/bluebird-midflap.png")
	defer rl.UnloadTexture(player_texture)

	pipe_texture := rl.LoadTexture("resources/pipe-green.png")
	defer rl.UnloadTexture(pipe_texture)

	player := Fish {
		pos      = rl.Vector2{WIDTH / 3, WIDTH / 3},
		size     = rl.Vector2{20, 20},
		rotation = 0,
		v_speed  = 0,
		h_speed  = FISH_H_SPEED,
	}

	walls := [TOTAL_WALLS * 2]WallSection{}
	initWalls(walls[:], f32(pipe_texture.height))

	spawn: f32 = SPAWN_INTERVAL

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		// Update
		updateFish(&player, delta)
		updateWalls(walls[:], delta)

		background_scroll -= 0.1
		if background_scroll <= -f32(background.width) do background_scroll = 0

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
		rl.DrawTextureEx(
			background,
			rl.Vector2{f32(background.width * 3) + background_scroll, 0},
			0,
			1.0,
			rl.WHITE,
		)

		rl.DrawTextureEx(player_texture, player.pos, player.rotation, 1.0, rl.WHITE)

		for w, index in walls {
			if index % 2 == 0 {
				rl.DrawTextureEx(pipe_texture, w.pos, 180, 1.0, rl.WHITE)
			} else {
				rl.DrawTextureEx(pipe_texture, w.pos, 0, 1.0, rl.WHITE)
			}
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

updateWalls :: proc(walls: []WallSection, delta: f32) {
	for &w, index in walls {
		if w.pos.x + WALL_WIDTH < 0 {
			w.pos.x = f32(WIDTH + WALL_WIDTH + WALL_GAP)
		} else {
			w.pos.x -= w.v_speed * delta
		}
	}
}

initWalls :: proc(walls: []WallSection, texture_height: f32) {
	index := 0
	for index < len(walls) {
		walls[index] = WallSection {
			pos     = rl.Vector2{f32(WIDTH + WALL_WIDTH + index * WALL_GAP), GAP_START},
			size    = rl.Vector2{WALL_WIDTH, 200},
			v_speed = 200,
		}
		walls[index + 1] = WallSection {
			pos     = rl.Vector2{f32(WIDTH + index * WALL_GAP), 200 + GAP_HEIGHT},
			size    = rl.Vector2{WALL_WIDTH, HEIGHT - (200 + GAP_HEIGHT)},
			v_speed = 200,
		}
		index += 2
	}
}
