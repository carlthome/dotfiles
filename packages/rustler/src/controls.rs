use crate::MainState;
use ggez::Context;
use ggez::glam::Vec2;
use ggez::input::keyboard::KeyCode;

pub fn handle_player_movement(
    state: &mut MainState,
    ctx: &mut Context,
    dt: f32,
    speed: f32,
    width: f32,
    height: f32,
) {
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

    // Increase player speed and speed boost based on score.
    let base_speed = speed * (1.0 + state.score as f32 * 0.1);
    let speed_boost_multiplier = 2.1 + state.score as f32 * 0.1;

    let mut move_speed = base_speed;

    // Apply speed boost if available.
    if state.boost_timer > 0.0 {
        move_speed *= speed_boost_multiplier;
    }

    // Handle player movement direction and velocity.
    let acceleration = 1000.0;
    let friction = 0.8;
    if dir != Vec2::ZERO {
        // Accelerate player in the input direction.
        let dir = dir.normalize();
        state.player_vel = state.player_vel * friction + dir * acceleration * dt;
        state.last_dir = dir;
        println!("Player input direction: {:?}", dir);
    } else {
        // Decelerate player if no input is given.
        state.player_vel *= friction;
        println!("No input, applying friction: {:?}", state.player_vel);
    }

    // Apply speed limit to player velocity.
    if state.player_vel.length() > move_speed {
        state.player_vel = state.player_vel.normalize() * move_speed;
    }

    println!("Player velocity: {:?}", state.player_vel);

    // Update player position with velocity and clamp to screen bounds.
    state.player_pos += state.player_vel * dt;
    state.player_pos.x = state.player_pos.x.clamp(0.0, width - crate::PLAYER_SIZE);
    state.player_pos.y = state.player_pos.y.clamp(0.0, height - crate::PLAYER_SIZE);
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
