use rand::Rng;

use ggez::audio::{SoundSource, Source};
use ggez::glam::Vec2;
use ggez::graphics::{Canvas, Color, DrawParam, Rect, Text};
use ggez::{
    Context, ContextBuilder, GameResult,
    conf::WindowMode,
    event::{self, EventHandler},
    graphics::Mesh,
    input::keyboard::KeyInput,
};
use std::{env, path};

mod controls;
mod enemies;
mod graphics;
mod levels;
mod spawnings;
use crate::controls::{handle_key_down_event, handle_player_movement};
use crate::enemies::{CrabType, EnemyCrab};
use crate::graphics::{draw_crab, draw_flashlight, draw_grass, draw_rustler};
use crate::levels::{Level, get_levels};
use crate::spawnings::spawn_enemies;

const PLAYER_SIZE: f32 = 48.0;
const CRAB_SIZE: f32 = 36.0;
const SPEED: f32 = 100.0;
const NUM_CRABS: usize = 5;

struct MainState {
    player_pos: Vec2,        // Player position
    player_vel: Vec2,        // Player velocity (for smooth movement)
    mouse_pos: Vec2,         // Mouse position for flashlight aiming
    crabs: Vec<EnemyCrab>,   // List of crabs in the game
    score: usize,            // Current score
    spawn_timer: f32,        // Timer for spawning new crabs
    time_elapsed: f32,       // Time since game start
    game_over: bool,         // Game over flag
    success_sound: Source,   // Sound effect for catching crabs
    success_sound2: Source,  // Sound effects for catching crabs
    show_instructions: bool, // Show instructions screen
    last_dir: Vec2,          // Last movement direction for flashlight
    shake_timer: f32,        // Timer for crab shake effect
    time_since_catch: f32,   // Time since last crab was caught
    boost_timer: f32,        // Timer for speed boost
    boost_cooldown: f32,     // Cooldown to prevent holding space
    levels: Vec<Level>,      // List of levels with patterns
    current_level: usize,    // Current level index
    current_pattern: usize,  // Current pattern index within the level
    pattern_timer: f32,      // Timer for current pattern duration
    debug_mode: bool,        // Debug mode flag
    flashlight_on: bool,     // Whether the flashlight is on
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
        let crabs = (0..0)
            .map(|i| {
                let angle = i as f32 * std::f32::consts::TAU / NUM_CRABS as f32;
                let pos = center + Vec2::new(angle.cos(), angle.sin()) * radius;
                let vel_angle = rng.random_range(0.0..std::f32::consts::TAU);
                let vel = Vec2::new(vel_angle.cos(), vel_angle.sin());
                let crab_type = CrabType::random(&mut rng);
                let speed = rng.random_range(crab_type.speed_range());
                let scale = rng.random_range(crab_type.scale_range());
                EnemyCrab {
                    pos,
                    vel,
                    speed,
                    caught: false,
                    scale,
                    spawn_time: 0.0,
                    crab_type,
                    spooked_timer: 0.0, // Initialize spooked timer
                }
            })
            .collect();
        let success_sound = Source::new(ctx, "/success.ogg")?;
        let success_sound2 = Source::new(ctx, "/success2.ogg")?;
        let levels = get_levels();
        Ok(MainState {
            player_pos,
            player_vel: Vec2::ZERO,
            mouse_pos: Vec2::new(virtual_width / 2.0, virtual_height / 2.0),
            crabs,
            score: 0,
            spawn_timer: 0.0,
            time_elapsed: 0.0,
            game_over: false,
            success_sound,
            success_sound2,
            show_instructions: true,
            last_dir: Vec2::new(0.0, -1.0),
            shake_timer: 0.0,
            time_since_catch: 0.0,
            boost_timer: 0.0,
            boost_cooldown: 0.0,
            levels,
            current_level: 0,
            current_pattern: 0,
            pattern_timer: 0.0,
            debug_mode: false,
            flashlight_on: true, // Flashlight starts on
        })
    }

    fn handle_crab_catching(&mut self, ctx: &mut Context) {
        for crab in &mut self.crabs {
            if !crab.caught
                && (self.player_pos.x - crab.pos.x).abs() < (PLAYER_SIZE + crab.scale) / 2.0
                && (self.player_pos.y - crab.pos.y).abs() < (PLAYER_SIZE + crab.scale) / 2.0
            {
                crab.caught = true;
                self.score += 1;
                self.shake_timer = 0.4;
                self.time_since_catch = 0.0;
                let mut rng = rand::rng();
                if rng.random_range(0..10) == 0 {
                    let _ = self.success_sound2.play_detached(ctx);
                } else {
                    let _ = self.success_sound.play_detached(ctx);
                }
            }
        }
    }

    fn update_crabs(&mut self, dt: f32) {
        // Calculate flashlight direction
        let flashlight_dir = (self.mouse_pos - self.player_pos).normalize_or_zero();
        let flashlight_cone_angle = 0.7; // radians, ~40 degrees cone
        let flashlight_range = 320.0; // pixels
        for crab in &mut self.crabs {
            if !crab.caught {
                crab.spawn_time += dt;
                let distance = self.player_pos.distance(crab.pos);
                let to_crab = (crab.pos - self.player_pos).normalize_or_zero();
                let angle_to_crab = flashlight_dir.angle_between(to_crab).abs();
                let crab_in_light = self.flashlight_on
                    && distance < flashlight_range
                    && angle_to_crab < flashlight_cone_angle;
                if crab_in_light {
                    // Crab scurries away from flashlight direction
                    let away_dir = (crab.pos - self.player_pos).normalize_or_zero();
                    crab.vel = away_dir * crab.vel.length().max(1.0);

                    // Increase speed when scared, but clamp to max 2x normal
                    let max_scared_speed = crab.crab_type.speed_range().end * 2.0;
                    crab.speed = (crab.speed * 1.15)
                        .clamp(crab.crab_type.speed_range().start, max_scared_speed);
                    crab.spooked_timer = 0.7; // Spooked for 0.7 seconds
                }
                // Calm down after timer
                if crab.spooked_timer > 0.0 {
                    crab.spooked_timer -= dt;
                    if crab.spooked_timer < 0.0 {
                        crab.spooked_timer = 0.0;
                    }
                }

                // If player is within 150 pixels, increase crab speed up to 2x
                let mut speed_multiplier = 1.0;
                if distance < 150.0 {
                    speed_multiplier = 2.0 - (distance / 150.0);
                    speed_multiplier = speed_multiplier.clamp(1.0, 2.0);
                }

                // Add speed boost for age
                let age_boost = 1.0 + (crab.spawn_time / 10.0).min(1.5); // up to 2.5x
                crab.pos += crab.vel * crab.speed * speed_multiplier * age_boost * dt;

                // Bounce off walls
                if crab.pos.x < 0.0 || crab.pos.x > 1280.0 - crab.scale {
                    crab.vel.x = -crab.vel.x;
                    crab.pos.x = crab.pos.x.clamp(0.0, 1280.0 - crab.scale);
                }
                if crab.pos.y < 0.0 || crab.pos.y > 960.0 - crab.scale {
                    crab.vel.y = -crab.vel.y;
                    crab.pos.y = crab.pos.y.clamp(0.0, 960.0 - crab.scale);
                }
            }
        }
    }

    fn start_current_pattern(&mut self) {
        let (w, h) = (1280.0, 960.0);
        let mut rng = rand::rng();
        let level = &self.levels[self.current_level];
        let pat = &level.patterns[self.current_pattern];
        self.crabs.extend(spawn_enemies(
            pat.pattern.clone(),
            pat.count,
            (w, h),
            &mut rng,
        ));
        self.pattern_timer = pat.duration;
    }

    fn advance_pattern(&mut self) {
        self.current_pattern += 1;
        let level = &self.levels[self.current_level];
        if self.current_pattern >= level.patterns.len() {
            self.current_level = (self.current_level + 1) % self.levels.len();
            self.current_pattern = 0;
        }
        self.start_current_pattern();
    }

    fn reset_game(&mut self) {
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
                let crab_type = CrabType::random(&mut rng);
                let speed = rng.random_range(crab_type.speed_range());
                let scale = rng.random_range(crab_type.scale_range());
                EnemyCrab {
                    pos,
                    vel,
                    speed,
                    caught: false,
                    scale,
                    spawn_time: 0.0,
                    crab_type,
                    spooked_timer: 0.0, // Initialize spooked timer
                }
            })
            .collect();
        self.player_pos = player_pos;
        self.score = 0;
        self.spawn_timer = 0.0;
        self.time_elapsed = 0.0;
        self.game_over = false;
        self.boost_timer = 0.0;
        self.boost_cooldown = 0.0;
        self.current_level = 0;
        self.current_pattern = 0;
        self.start_current_pattern();
    }

    fn draw_instructions_screen(
        &self,
        ctx: &mut Context,
        virtual_canvas: &mut Canvas,
        virtual_width: f32,
        virtual_height: f32,
        _scale_x: f32,
        _scale_y: f32,
    ) -> GameResult {
        // Draw a solid background to hide all graphics
        let bg = Mesh::new_rectangle(
            ctx,
            ggez::graphics::DrawMode::fill(),
            Rect::new(0.0, 0.0, virtual_width, virtual_height),
            Color::BLACK,
        )?;
        virtual_canvas.draw(&bg, DrawParam::default());

        // Draw grass background in instructions screen (always bright)
        graphics::draw_grass(ctx, virtual_canvas, virtual_width, virtual_height, false)?;

        // Draw game title
        let mut title = Text::new("Crab Rustler");
        title.set_scale(112.0);
        let title_width = title.measure(ctx)?.x;
        let title_height = title.measure(ctx)?.y;

        // Draw shadow
        virtual_canvas.draw(
            &title,
            DrawParam::default()
                .dest(Vec2::new(
                    (virtual_width - title_width) / 2.0 + 8.0,
                    (virtual_height - title_height) / 4.0 + 8.0,
                ))
                .color(Color::from_rgba(0, 0, 0, 180))
                .rotation(0.05),
        );

        // Draw main title with a wavy color effect
        for (i, ch) in "Crab Rustler".chars().enumerate() {
            let frag = ggez::graphics::TextFragment::new(ch).scale(112.0);
            let ch_text = Text::new(frag);
            let x = (virtual_width - title_width) / 2.0 + i as f32 * 60.0;
            let y = (virtual_height - title_height) / 4.0 + (i as f32 * 0.5).sin() * 16.0;

            let color = Color::from_rgb(
                220 + ((i as f32 * 0.7).sin() * 35.0) as u8,
                80 + ((i as f32 * 1.3).cos() * 140.0) as u8,
                255 - (i as u8 * 7),
            );
            virtual_canvas.draw(
                &ch_text,
                DrawParam::default()
                    .dest(Vec2::new(x, y))
                    .color(color)
                    .rotation((i as f32 * 0.1).sin() * 0.08),
            );
        }

        // Draw instructions text centered
        let text = Text::new(
            "Catch all the crabs quickly!\n\nUse the arrow keys to move.\n\nPress Space or Enter to start.",
        );
        let text_width = text.measure(ctx)?.x;
        let text_height = text.measure(ctx)?.y;
        virtual_canvas.draw(
            &text,
            DrawParam::default()
                .dest(Vec2::new(
                    (virtual_width - text_width) / 2.0,
                    (virtual_height - text_height) / 2.0 + 100.0,
                ))
                .color(Color::from_rgb(255, 255, 0)),
        );
        Ok(())
    }

    fn draw_crabs_with_shake(&self, ctx: &mut Context, virtual_canvas: &mut Canvas) -> GameResult {
        use rand::Rng;
        let mut rng = rand::rng();
        for (i, crab) in self.crabs.iter().enumerate() {
            if !crab.caught {
                let mut pos = crab.pos;
                let mut shake_strength = 0.0;
                if crab.spooked_timer > 0.0 {
                    shake_strength = 18.0 * crab.spooked_timer;
                } else if self.shake_timer > 0.0 {
                    shake_strength = 18.0 * self.shake_timer;
                }
                if shake_strength > 0.0 {
                    let t = self.time_elapsed * 30.0 + i as f32 * 2.0;
                    pos.x += (t).sin() * shake_strength
                        + rng.random_range(-shake_strength..=shake_strength) * 0.3;
                    pos.y += (t * 1.3).cos() * shake_strength
                        + rng.random_range(-shake_strength..=shake_strength) * 0.3;
                }
                draw_crab(ctx, virtual_canvas, crab)?;
            }
        }
        Ok(())
    }

    fn draw_game_over_screen(&self, ctx: &mut Context, virtual_canvas: &mut Canvas) -> GameResult {
        let box_width = 600.0;
        let box_height = 200.0;
        let box_x = 340.0;
        let box_y = 380.0;
        let bg_box = Mesh::new_rectangle(
            ctx,
            ggez::graphics::DrawMode::fill(),
            Rect::new(box_x, box_y, box_width, box_height),
            Color::from_rgba(40, 0, 80, 180),
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
        Ok(())
    }
}

impl EventHandler for MainState {
    fn update(&mut self, ctx: &mut Context) -> GameResult {
        if self.show_instructions || self.game_over {
            return Ok(());
        }
        let dt = ctx.time.delta().as_secs_f32();
        self.time_elapsed += dt;
        self.time_since_catch += dt;
        if self.shake_timer > 0.0 {
            self.shake_timer -= dt;
            if self.shake_timer < 0.0 {
                self.shake_timer = 0.0;
            }
        }
        if self.boost_timer > 0.0 {
            self.boost_timer -= dt;
            if self.boost_timer < 0.0 {
                self.boost_timer = 0.0;
            }
        }
        if self.boost_cooldown > 0.0 {
            self.boost_cooldown -= dt;
            if self.boost_cooldown < 0.0 {
                self.boost_cooldown = 0.0;
            }
        }
        let virtual_width = ctx.gfx.window().inner_size().width as f32;
        let virtual_height = ctx.gfx.window().inner_size().height as f32;
        handle_player_movement(self, ctx, dt, SPEED, virtual_width, virtual_height);
        self.handle_crab_catching(ctx);
        self.update_crabs(dt);
        self.pattern_timer -= dt;

        // Game over if number of crabs reaches 100.
        if self.crabs.len() >= 100 {
            self.game_over = true;
            return Ok(());
        }
        if self.crabs.iter().all(|c| c.caught) || self.pattern_timer <= 0.0 {
            self.advance_pattern();
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
        virtual_canvas.set_screen_coordinates(Rect::new(0.0, 0.0, virtual_width, virtual_height));
        use ggez::graphics::BlendMode;
        virtual_canvas.set_blend_mode(BlendMode::ALPHA);
        virtual_canvas.set_sampler(graphics::Sampler::nearest_clamp());

        if self.show_instructions {
            self.draw_instructions_screen(
                ctx,
                &mut virtual_canvas,
                virtual_width,
                virtual_height,
                scale_x,
                scale_y,
            )?;
            virtual_canvas.finish(ctx)?;
            return Ok(());
        }

        if !self.game_over {
            draw_grass(
                ctx,
                &mut virtual_canvas,
                virtual_width,
                virtual_height,
                true,
            )?;

            // Calculate flashlight direction from player to mouse
            let flashlight_dir = (self.mouse_pos - self.player_pos).normalize_or_zero();
            if self.flashlight_on {
                draw_flashlight(
                    ctx,
                    &mut virtual_canvas,
                    self.player_pos,
                    flashlight_dir,
                    virtual_width,
                    virtual_height,
                    self.time_since_catch,
                )?;
            }
            draw_rustler(ctx, &mut virtual_canvas, self.player_pos)?;
            self.draw_crabs_with_shake(ctx, &mut virtual_canvas)?;
            let text = Text::new(format!("Crabs caught: {}", self.score));
            virtual_canvas.draw(
                &text,
                DrawParam::default()
                    .dest(Vec2::new(10.0, 10.0))
                    .color(Color::from_rgb(255, 255, 00)),
            );

            // Draw stamina bar for boost timer/cooldown
            let bar_x = 10.0;
            let bar_y = 50.0;
            let bar_width = 220.0;
            let bar_height = 18.0;
            let max_boost = 0.18;
            let max_cooldown = 0.08; // boost_cooldown max value
            let boost_ratio = (self.boost_timer / max_boost).clamp(0.0, 1.0);
            let cooldown_ratio = (self.boost_cooldown / max_cooldown).clamp(0.0, 1.0);

            // Draw background bar
            let bg_bar = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::fill(),
                Rect::new(bar_x, bar_y, bar_width, bar_height),
                Color::from_rgb(40, 40, 40),
            )?;
            virtual_canvas.draw(&bg_bar, DrawParam::default());

            // Draw boost timer (yellow)
            if boost_ratio > 0.0 {
                let boost_bar = Mesh::new_rectangle(
                    ctx,
                    ggez::graphics::DrawMode::fill(),
                    Rect::new(bar_x, bar_y, bar_width * boost_ratio, bar_height),
                    Color::from_rgb(255, 220, 40),
                )?;
                virtual_canvas.draw(&boost_bar, DrawParam::default());
            }

            // Draw cooldown (red, overlays boost)
            if cooldown_ratio > 0.0 {
                let cooldown_bar = Mesh::new_rectangle(
                    ctx,
                    ggez::graphics::DrawMode::fill(),
                    Rect::new(bar_x, bar_y, bar_width * cooldown_ratio, bar_height),
                    Color::from_rgb(220, 60, 60),
                )?;
                virtual_canvas.draw(&cooldown_bar, DrawParam::default());
            }

            // Draw stamina bar border
            let border = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::stroke(2.0),
                Rect::new(bar_x, bar_y, bar_width, bar_height),
                Color::from_rgb(255, 255, 255),
            )?;
            virtual_canvas.draw(&border, DrawParam::default());

            // Draw label
            let label = Text::new("Stamina (Space)");
            virtual_canvas.draw(
                &label,
                DrawParam::default()
                    .dest(Vec2::new(bar_x, bar_y - 22.0))
                    .color(Color::from_rgb(255, 255, 255)),
            );
            if self.debug_mode {
                use crate::spawnings::SpawnPattern;
                let level = &self.levels[self.current_level];
                let pat = &level.patterns[self.current_pattern];
                let pattern_name = match &pat.pattern {
                    SpawnPattern::UniformRandom => "UniformRandom",
                    SpawnPattern::SineWave => "SineWave",
                    SpawnPattern::Circle => "Circle",
                    SpawnPattern::Cluster => "Cluster",
                    SpawnPattern::SingleRandom => "SingleRandom",
                };
                let debug_text = Text::new(format!(
                    "[DEBUG] Pattern: {} | Time left: {:.2}s",
                    pattern_name, self.pattern_timer
                ));
                virtual_canvas.draw(
                    &debug_text,
                    DrawParam::default()
                        .dest(Vec2::new(10.0, 40.0))
                        .color(Color::from_rgb(255, 100, 100)),
                );
            }
        } else {
            self.draw_game_over_screen(ctx, &mut virtual_canvas)?;
        }

        virtual_canvas.finish(ctx)?;
        Ok(())
    }

    fn key_down_event(&mut self, ctx: &mut Context, input: KeyInput, _repeat: bool) -> GameResult {
        use ggez::input::keyboard::KeyCode;
        if let Some(key) = input.keycode {
            if key == KeyCode::F {
                self.flashlight_on = !self.flashlight_on;
                return Ok(());
            }
        }
        if handle_key_down_event(self, ctx, input.keycode) {
            return Ok(());
        }
        Ok(())
    }

    fn mouse_motion_event(
        &mut self,
        ctx: &mut Context,
        x: f32,
        y: f32,
        _xrel: f32,
        _yrel: f32,
    ) -> GameResult {
        let window_size = ctx.gfx.window().inner_size();
        let scale_x = window_size.width as f32 / 1280.0;
        let scale_y = window_size.height as f32 / 960.0;
        self.mouse_pos = Vec2::new(x / scale_x, y / scale_y);
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
