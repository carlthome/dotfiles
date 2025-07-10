use rand::Rng;

use ggez::audio::{SoundSource, Source};
use ggez::glam::Vec2;
use ggez::{
    conf::WindowMode,
    event::{self, EventHandler},
    graphics::{Mesh, Text},
    input::keyboard::{KeyCode, KeyInput},
    Context, ContextBuilder, GameResult,
};
use std::{env, path};

mod graphics;
use crate::graphics::{draw_crab, draw_flashlight, draw_grass, draw_rustler};

const PLAYER_SIZE: f32 = 48.0;
const CRAB_SIZE: f32 = 36.0;
const SPEED: f32 = 200.0;
const NUM_CRABS: usize = 5;

struct Crab {
    pos: Vec2,
    vel: Vec2,  // Velocity direction
    speed: f32, // Speed
    caught: bool,
}

struct MainState {
    player_pos: Vec2,
    crabs: Vec<Crab>,
    score: usize,
    spawn_timer: f32,  // Timer for spawning new crabs
    time_elapsed: f32, // Time since game start
    game_over: bool,   // Game over flag
    success_sound: Source,
    success_sound2: Source,
    show_instructions: bool, // Show instructions screen
    last_dir: Vec2,          // Last movement direction for flashlight
    shake_timer: f32,        // Timer for crab shake effect
}

impl MainState {
    fn new(ctx: &mut Context) -> GameResult<MainState> {
        let virtual_width = 1280.0;
        let virtual_height = 960.0;
        let player_pos = Vec2::new(
            virtual_width / 2.0 - PLAYER_SIZE / 2.0,
            virtual_height / 2.0 - PLAYER_SIZE / 2.0,
        );
        let mut rng = rand::rng();
        // Place crabs in a circle around the center
        let center = Vec2::new(virtual_width / 2.0, virtual_height / 2.0);
        let radius = 220.0;
        let crabs = (0..NUM_CRABS)
            .map(|i| {
                let angle = i as f32 * std::f32::consts::TAU / NUM_CRABS as f32;
                let pos = center + Vec2::new(angle.cos(), angle.sin()) * radius;
                let vel_angle = rng.random_range(0.0..std::f32::consts::TAU);
                let vel = Vec2::new(vel_angle.cos(), vel_angle.sin());
                let speed = rng.random_range(30.0..70.0);
                Crab {
                    pos,
                    vel,
                    speed,
                    caught: false,
                }
            })
            .collect();
        let success_sound = Source::new(ctx, "/success.ogg")?;
        let success_sound2 = Source::new(ctx, "/success2.ogg")?;
        Ok(MainState {
            player_pos,
            crabs,
            score: 0,
            spawn_timer: 0.0,
            time_elapsed: 0.0,
            game_over: false,
            success_sound,
            success_sound2,
            show_instructions: true,
            last_dir: Vec2::new(0.0, -1.0), // Default facing up
            shake_timer: 0.0,
        })
    }
}

impl EventHandler for MainState {
    fn update(&mut self, ctx: &mut Context) -> GameResult {
        if self.show_instructions {
            return Ok(());
        }
        if self.game_over {
            return Ok(());
        }
        let dt = ctx.time.delta().as_secs_f32();
        self.time_elapsed += dt;
        if self.shake_timer > 0.0 {
            self.shake_timer -= dt;
            if self.shake_timer < 0.0 {
                self.shake_timer = 0.0;
            }
        }
        let mut dir = Vec2::ZERO;

        if ctx.keyboard.is_key_pressed(KeyCode::Up) {
            dir.y -= 1.0;
        }
        if ctx.keyboard.is_key_pressed(KeyCode::Down) {
            dir.y += 1.0;
        }
        if ctx.keyboard.is_key_pressed(KeyCode::Left) {
            dir.x -= 1.0;
        }
        if ctx.keyboard.is_key_pressed(KeyCode::Right) {
            dir.x += 1.0;
        }
        if dir != Vec2::ZERO {
            dir = dir.normalize();
            let speed = SPEED * (1.0 + self.score as f32 * 0.1); // Increase speed with score
            self.player_pos += dir * speed * dt;
            self.last_dir = dir; // Update last movement direction
        }

        // Clamp player to window
        self.player_pos.x = self.player_pos.x.clamp(0.0, 1280.0 - PLAYER_SIZE);
        self.player_pos.y = self.player_pos.y.clamp(0.0, 960.0 - PLAYER_SIZE);

        // Check for crab catches
        for crab in &mut self.crabs {
            if !crab.caught
                && (self.player_pos.x - crab.pos.x).abs() < (PLAYER_SIZE + CRAB_SIZE) / 2.0
                && (self.player_pos.y - crab.pos.y).abs() < (PLAYER_SIZE + CRAB_SIZE) / 2.0
            {
                crab.caught = true;
                self.score += 1;
                self.shake_timer = 0.4; // Start shake effect for all crabs
                                        // Play success.ogg most of the time, success2.ogg sometimes
                let mut rng = rand::rng();
                if rng.random_range(0..10) == 0 {
                    let _ = self.success_sound2.play_detached(ctx);
                } else {
                    let _ = self.success_sound.play_detached(ctx);
                }
            }
        }

        // End game if all crabs are caught
        if self.crabs.iter().all(|c| c.caught) {
            self.game_over = true;
            return Ok(());
        }

        // Move crabs
        for crab in &mut self.crabs {
            if !crab.caught {
                // Calculate distance to player
                let distance = self.player_pos.distance(crab.pos);
                // If player is within 150 pixels, increase crab speed up to 2x
                let mut speed_multiplier = 1.0;
                if distance < 150.0 {
                    // Linearly scale multiplier from 1.0 (far) to 2.0 (very close)
                    speed_multiplier = 2.0 - (distance / 150.0);
                    speed_multiplier = speed_multiplier.clamp(1.0, 2.0);
                }
                crab.pos += crab.vel * crab.speed * speed_multiplier * dt;
                // Bounce off walls
                if crab.pos.x < 0.0 || crab.pos.x > 1280.0 - CRAB_SIZE {
                    crab.vel.x = -crab.vel.x;
                    crab.pos.x = crab.pos.x.clamp(0.0, 1280.0 - CRAB_SIZE);
                }
                if crab.pos.y < 0.0 || crab.pos.y > 960.0 - CRAB_SIZE {
                    crab.vel.y = -crab.vel.y;
                    crab.pos.y = crab.pos.y.clamp(0.0, 960.0 - CRAB_SIZE);
                }
            }
        }

        self.spawn_timer += dt;
        if self.spawn_timer > 2.0 {
            let mut rng = rand::rng();
            let angle = rng.random_range(0.0..std::f32::consts::TAU);
            let vel = Vec2::new(angle.cos(), angle.sin());
            let speed = rng.random_range(30.0..70.0);
            let new_crab = Crab {
                pos: Vec2::new(
                    rng.random_range(50.0..1230.0),
                    rng.random_range(50.0..910.0),
                ),
                vel,
                speed,
                caught: false,
            };
            self.crabs.push(new_crab);
            self.spawn_timer = 0.0;
        }

        Ok(())
    }

    fn draw(&mut self, ctx: &mut Context) -> GameResult {
        use ggez::graphics::{self, Canvas, Color, DrawParam, Rect};
        let virtual_width = 1280.0;
        let virtual_height = 960.0;
        let window_size = ctx.gfx.window().inner_size();
        let scale_x = window_size.width as f32 / virtual_width;
        let scale_y = window_size.height as f32 / virtual_height;

        // Render to a virtual-resolution canvas
        let mut virtual_canvas = Canvas::from_frame(ctx, Color::from_rgb(100, 200, 100));
        virtual_canvas.set_screen_coordinates(Rect::new(0.0, 0.0, virtual_width, virtual_height)); // removed ?
        use ggez::graphics::BlendMode;
        virtual_canvas.set_blend_mode(BlendMode::ALPHA); // use a valid blend mode
        virtual_canvas.set_sampler(graphics::Sampler::nearest_clamp());

        // Draw everything to the virtual canvas
        draw_grass(ctx, &mut virtual_canvas)?;
        draw_flashlight(
            ctx,
            &mut virtual_canvas,
            self.player_pos,
            self.last_dir,
            virtual_width,
            virtual_height,
        )?; // Pass virtual_width and virtual_height

        if self.show_instructions {
            // Draw a solid background to hide all graphics
            let bg = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::fill(),
                Rect::new(0.0, 0.0, virtual_width, virtual_height),
                Color::BLACK,
            )?;
            virtual_canvas.draw(&bg, DrawParam::default().scale([scale_x, scale_y]));

            // Draw game title
            let mut title = Text::new("Crab Rustler");
            title.set_scale(96.0);
            virtual_canvas.draw(
                &title,
                DrawParam::default()
                    .dest(Vec2::new(340.0, 120.0))
                    .color(Color::WHITE),
            );
            let text = Text::new("Catch all the crabs quickly!\n\nUse the arrow keys to move.\n\nPress Space or Enter to start.");
            virtual_canvas.draw(
                &text,
                DrawParam::default()
                    .dest(Vec2::new(220.0, 320.0))
                    .color(Color::WHITE),
            );
            virtual_canvas.finish(ctx)?;
            return Ok(());
        }

        // Draw player
        if !self.game_over {
            draw_rustler(ctx, &mut virtual_canvas, self.player_pos)?;
        }
        use rand::Rng;
        let mut rng = rand::rng();
        for (i, crab) in self.crabs.iter().enumerate() {
            if !crab.caught {
                let mut pos = crab.pos;
                if self.shake_timer > 0.0 {
                    let shake_strength = 18.0 * self.shake_timer;
                    let t = self.time_elapsed * 30.0 + i as f32 * 2.0;
                    pos.x += (t).sin() * shake_strength
                        + rng.random_range(-shake_strength..=shake_strength) * 0.3;
                    pos.y += (t * 1.3).cos() * shake_strength
                        + rng.random_range(-shake_strength..=shake_strength) * 0.3;
                }
                draw_crab(ctx, &mut virtual_canvas, &Crab { pos, ..*crab })?;
            }
        }

        // Draw score or game over
        if self.game_over {
            // Draw a semi-transparent background box for readability
            let box_width = 600.0;
            let box_height = 200.0;
            let box_x = 340.0;
            let box_y = 380.0;
            let bg_box = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::fill(),
                Rect::new(box_x, box_y, box_width, box_height),
                Color::from_rgba(0, 0, 0, 180),
            )?;
            virtual_canvas.draw(&bg_box, DrawParam::default());
            let text = Text::new(format!(
                "Game Over!\nTime: {:.2} seconds\nPress Esc to quit.\n\nPress Space or Enter to try again.",
                self.time_elapsed
            ));
            virtual_canvas.draw(
                &text,
                DrawParam::default()
                    .dest(Vec2::new(370.0, 400.0))
                    .color(Color::WHITE),
            );
        } else {
            let text = Text::new(format!("Crabs caught: {}", self.score));
            virtual_canvas.draw(
                &text,
                DrawParam::default()
                    .dest(Vec2::new(10.0, 10.0))
                    .color(Color::WHITE),
            );
        }
        virtual_canvas.finish(ctx)?;
        Ok(())
    }

    fn key_down_event(&mut self, ctx: &mut Context, input: KeyInput, _repeat: bool) -> GameResult {
        if self.show_instructions {
            if let Some(key) = input.keycode {
                if key == KeyCode::Space || key == KeyCode::Return {
                    self.show_instructions = false;
                }
            }
            return Ok(());
        }
        if self.game_over {
            if let Some(key) = input.keycode {
                if key == KeyCode::Space || key == KeyCode::Return {
                    // Reset game state
                    let virtual_width = 1280.0;
                    let virtual_height = 960.0;
                    let player_pos = Vec2::new(
                        virtual_width / 2.0 - PLAYER_SIZE / 2.0,
                        virtual_height / 2.0 - PLAYER_SIZE / 2.0,
                    );
                    let mut rng = rand::rng();
                    let center = Vec2::new(virtual_width / 2.0, virtual_height / 2.0);
                    let radius = 220.0;
                    self.crabs = (0..NUM_CRABS)
                        .map(|i| {
                            let angle = i as f32 * std::f32::consts::TAU / NUM_CRABS as f32;
                            let pos = center + Vec2::new(angle.cos(), angle.sin()) * radius;
                            let vel_angle = rng.random_range(0.0..std::f32::consts::TAU);
                            let vel = Vec2::new(vel_angle.cos(), vel_angle.sin());
                            let speed = rng.random_range(30.0..70.0);
                            Crab {
                                pos,
                                vel,
                                speed,
                                caught: false,
                            }
                        })
                        .collect();
                    self.player_pos = player_pos;
                    self.score = 0;
                    self.spawn_timer = 0.0;
                    self.time_elapsed = 0.0;
                    self.game_over = false;
                    return Ok(());
                }
            }
        }
        if let Some(KeyCode::Escape) = input.keycode {
            ctx.request_quit();
        }
        Ok(())
    }
}

fn main() -> GameResult {
    let resource_dir = if let Ok(manifest_dir) = env::var("CARGO_MANIFEST_DIR") {
        let mut path = path::PathBuf::from(manifest_dir);
        path.push("resources");
        path
    } else {
        path::PathBuf::from("./resources")
    };

    let (mut ctx, event_loop) = ContextBuilder::new("rustler", "carlthome")
        .add_resource_path(resource_dir)
        .window_mode(WindowMode::default().fullscreen_type(ggez::conf::FullscreenType::Desktop))
        .build()?;
    let state = MainState::new(&mut ctx)?;
    event::run(ctx, event_loop, state)
}
