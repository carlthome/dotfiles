use crate::MainState;
use ggez::Context;
use ggez::glam::Vec2;
use ggez::input::keyboard::KeyCode;

pub fn handle_player_movement(state: &mut MainState, ctx: &mut Context, dt: f32, speed: f32) {
    let mut dir = Vec2::ZERO;
    if ctx.keyboard.is_key_pressed(KeyCode::Up) || ctx.keyboard.is_key_pressed(KeyCode::W) {
        dir.y -= 1.0;
    }
    if ctx.keyboard.is_key_pressed(KeyCode::Down) || ctx.keyboard.is_key_pressed(KeyCode::S) {
        dir.y += 1.0;
    }
    if ctx.keyboard.is_key_pressed(KeyCode::Left) || ctx.keyboard.is_key_pressed(KeyCode::A) {
        dir.x -= 1.0;
    }
    if ctx.keyboard.is_key_pressed(KeyCode::Right) || ctx.keyboard.is_key_pressed(KeyCode::D) {
        dir.x += 1.0;
    }
    let mut move_speed = speed * (1.0 + state.score as f32 * 0.1);
    if state.boost_timer > 0.0 {
        move_speed *= 2.1;
    }
    if dir != Vec2::ZERO {
        let dir = dir.normalize();
        state.player_pos += dir * move_speed * dt;
        state.last_dir = dir;
    }
    state.player_pos.x = state.player_pos.x.clamp(0.0, 1280.0 - crate::PLAYER_SIZE);
    state.player_pos.y = state.player_pos.y.clamp(0.0, 960.0 - crate::PLAYER_SIZE);
}

pub fn handle_key_down_event(
    state: &mut MainState,
    ctx: &mut Context,
    keycode: Option<KeyCode>,
) -> bool {
    if let Some(key) = keycode {
        if state.show_instructions {
            if key == KeyCode::Space || key == KeyCode::Return {
                state.show_instructions = false;
                return true;
            }
        } else if state.game_over {
            if key == KeyCode::Space || key == KeyCode::Return {
                state.reset_game();
                return true;
            }
        } else {
            if key == KeyCode::Space {
                if state.boost_cooldown <= 0.0 {
                    state.boost_timer = 0.18;
                    state.boost_cooldown = 0.08;
                }
            }
            if key == KeyCode::Escape {
                ctx.request_quit();
            }
            if key == KeyCode::F2 {
                state.debug_mode = !state.debug_mode;
            }
        }
    }
    false
}
