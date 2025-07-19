mod controls;
mod enemies;
mod graphics;
mod levels;
mod spawnings;
use std::default;
use std::{env, fs, path};

use ggez::audio::SoundSource;
use ggez::audio::Source;
use ggez::conf::WindowMode;
use ggez::event::{self, EventHandler};
use ggez::glam::Vec2;
use ggez::graphics::{
    BlendMode, Canvas, ClampMode, Color, DrawParam, Image, Mesh, Rect, Sampler, ShaderBuilder, Text,
};
use ggez::input::keyboard::{KeyCode, KeyInput};
use ggez::{Context, ContextBuilder, GameResult};
use rand::Rng;
use rand::prelude::IndexedRandom;
use spawnings::SpawnPattern;

use crate::controls::{handle_key_down_event, handle_player_movement};
use crate::enemies::{CrabType, EnemyCrab};
use crate::graphics::{draw_crab, draw_flashlight, draw_grass, draw_rustler};
use crate::levels::{Level, get_levels};
use crate::spawnings::spawn_enemies;

const PLAYER_SIZE: f32 = 48.0;
const CRAB_SIZE: f32 = 36.0;
const SPEED: f32 = 200.0;

struct GameSounds {
    upgrade: Source,
    success: Source,
    success2: Source,
    // Add more sounds here as needed
}

struct Flashlight {
    on: bool,
    cone_upgrade: f32,
    range_upgrade: f32,
    laser_level: u32,
}

struct MainState {
    player_pos: Vec2,               // Player position
    player_vel: Vec2,               // Player velocity (for smooth movement)
    mouse_pos: Vec2,                // Mouse position for flashlight aiming
    crabs: Vec<EnemyCrab>,          // List of crabs in the game
    score: usize,                   // Current score
    spawn_timer: f32,               // Timer for spawning new crabs
    time_elapsed: f32,              // Time since game start
    game_over: bool,                // Game over flag
    sounds: GameSounds,             // All game sound effects
    flashlight: Flashlight,         // Flashlight settings and upgrades
    show_instructions: bool,        // Show instructions screen
    last_dir: Vec2,                 // Last movement direction for flashlight
    shake_timer: f32,               // Timer for crab shake effect
    time_since_catch: f32,          // Time since last crab was caught
    boost_timer: f32,               // Timer for speed boost
    boost_cooldown: f32,            // Cooldown to prevent holding space
    levels: Vec<Level>,             // List of levels with patterns
    current_level: usize,           // Current level index
    current_pattern: usize,         // Current pattern index within the level
    pattern_timer: f32,             // Timer for current pattern duration
    debug_mode: bool,               // Debug mode flag
    pending_upgrade: bool,          // Whether upgrade screen should be shown
    best_time: f32,                 // Fastest time to catch all crabs
    width: f32,                     // Virtual width of the game
    height: f32,                    // Virtual height of the game
    shader: ggez::graphics::Shader, // Shader for grass rendering
    level_title: String,            // Title of the current level
    level_title_timer: f32,         // Timer for displaying level title
    texture: Image,                 // Grass texture for background
}

impl MainState {
    fn new(ctx: &mut Context) -> GameResult<MainState> {
        let width = 1280.0;
        let height = 960.0;

        // Player starts in the center always.
        let player_pos = Vec2::new(
            width / 2.0 - PLAYER_SIZE / 2.0,
            height / 2.0 - PLAYER_SIZE / 2.0,
        );

        // TODO Load all sound effects.
        let sounds = GameSounds {
            upgrade: Source::new(ctx, "/upgrade.ogg")?,
            success: Source::new(ctx, "/success.ogg")?,
            success2: Source::new(ctx, "/success2.ogg")?,
            // Add more sounds here as needed
        };

        // Load grass texture.
        let texture = Image::from_path(ctx, "/grass.png")?;

        // Get levels.
        let levels = get_levels();

        // Load best time from file
        let best_time = fs::read_to_string("best_time.txt")
            .ok()
            .and_then(|s| s.parse::<f32>().ok())
            .unwrap_or(f32::MAX);

        // Initialize list of crabs.
        let crabs: Vec<EnemyCrab> = [].to_vec();

        let shader = ShaderBuilder::new()
            .vertex_path("/grass.wgsl")
            .fragment_path("/grass.wgsl")
            .build(&ctx.gfx)?;

        let flashlight = Flashlight {
            on: true,
            cone_upgrade: 0.0,
            range_upgrade: 0.0,
            laser_level: 0,
        };

        Ok(MainState {
            player_pos,
            player_vel: Vec2::ZERO,
            mouse_pos: Vec2::ZERO,
            crabs,
            score: 0,
            spawn_timer: 0.0,
            time_elapsed: 0.0,
            game_over: false,
            sounds,
            flashlight,
            show_instructions: true,
            last_dir: Vec2::ZERO,
            shake_timer: 0.0,
            time_since_catch: 0.0,
            boost_timer: 0.0,
            boost_cooldown: 0.0,
            levels,
            current_level: 0,
            current_pattern: 0,
            pattern_timer: 0.0,
            debug_mode: true,
            pending_upgrade: false,
            best_time,
            width,
            height,
            shader,
            level_title: String::new(),
            level_title_timer: 0.0,
            texture,
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
                if rng.random_range(0..5) == 0 {
                    let _ = self.sounds.success2.play_detached(ctx);
                } else {
                    let _ = self.sounds.success.play_detached(ctx);
                }
                if self.score > 0 && self.score % 10 == 0 {
                    let _ = self.sounds.upgrade.play_detached(ctx);
                    self.pending_upgrade = true;
                }
            }
        }
    }

    fn update_crabs(&mut self, dt: f32, area: (f32, f32)) {
        // Calculate flashlight direction.
        let flashlight_dir = (self.mouse_pos - self.player_pos).normalize_or_zero();

        let base_cone_angle = std::f32::consts::FRAC_PI_3;
        let base_range = 320.0;

        let flashlight_cone_angle = base_cone_angle + self.flashlight.cone_upgrade;
        let flashlight_range = base_range + self.flashlight.range_upgrade;

        for crab in &mut self.crabs {
            if !crab.caught {
                crab.spawn_time += dt;

                // If crab is spooked, it will move towards the player.
                let distance = self.player_pos.distance(crab.pos);
                let to_crab = (crab.pos - self.player_pos).normalize_or_zero();
                let angle_to_crab = flashlight_dir.angle_between(to_crab).abs();

                // Check if crab is within flashlight light.
                let crab_in_light = self.flashlight.on
                    && distance < flashlight_range
                    && angle_to_crab < flashlight_cone_angle;

                if crab_in_light {
                    // Crab is gently attracted to the player's position (sauntering, not rocketing)
                    let toward_dir = (self.player_pos - crab.pos).normalize_or_zero();
                    let max_speed = crab.crab_type.speed_range().end;
                    let min_speed = crab.crab_type.speed_range().start;

                    // Instead of instantly max speed, interpolate velocity and use a gentle boost.
                    let gentle_speed = min_speed + (max_speed - min_speed) * 0.10;
                    crab.vel = crab.vel.lerp(toward_dir * gentle_speed, 0.01);
                    crab.speed = gentle_speed;
                    crab.spooked_timer = 0.7;
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

                // Older crabs are faster so the player should catch them early.
                let age_boost = 1.0 + (crab.spawn_time / 10.0).min(1.5);
                crab.pos += crab.vel * crab.speed * speed_multiplier * age_boost * dt;

                // Bounce off walls.
                let (width, height) = area;
                if crab.pos.x < 0.0 || crab.pos.x > width - crab.scale {
                    crab.vel.x = -crab.vel.x;
                    crab.pos.x = crab.pos.x.clamp(0.0, width - crab.scale);
                }
                if crab.pos.y < 0.0 || crab.pos.y > height - crab.scale {
                    crab.vel.y = -crab.vel.y;
                    crab.pos.y = crab.pos.y.clamp(0.0, height - crab.scale);
                }
            }
        }
    }

    fn start_current_pattern(&mut self, area: (f32, f32)) {
        let mut rng = rand::rng();
        let level = &self.levels[self.current_level];
        let p = &level.patterns[self.current_pattern];
        let crabs = spawn_enemies(p.pattern.clone(), p.count, area, &mut rng);
        self.crabs.extend(crabs);
        self.pattern_timer = p.duration;
    }

    fn advance_pattern(&mut self) {
        self.current_pattern += 1;
        let level = &self.levels[self.current_level];
        if self.current_pattern >= level.patterns.len() {
            self.current_level = (self.current_level + 1) % self.levels.len();
            self.current_pattern = 0;
            self.level_title = level.title.clone();
            self.level_title_timer = 1.0;
        }
        let area = (self.width, self.height);
        self.start_current_pattern(area);
    }

    fn reset_game(&mut self) {
        let width = self.width;
        let height = self.height;
        let player_pos = Vec2::new(
            width / 2.0 - PLAYER_SIZE / 2.0,
            height / 2.0 - PLAYER_SIZE / 2.0,
        );
        self.crabs = Vec::default();
        self.player_pos = player_pos;
        self.score = 0;
        self.spawn_timer = 0.0;
        self.time_elapsed = 0.0;
        self.game_over = false;
        self.boost_timer = 0.0;
        self.boost_cooldown = 0.0;
        self.current_level = 0;
        self.current_pattern = 0;
        self.start_current_pattern((width, height));
    }

    fn draw_instructions_screen(
        &self,
        ctx: &mut Context,
        canvas: &mut Canvas,
        width: f32,
        height: f32,
    ) -> GameResult {
        // Draw a solid background to hide all graphics
        let bg = Mesh::new_rectangle(
            ctx,
            ggez::graphics::DrawMode::fill(),
            Rect::new(0.0, 0.0, width, height),
            Color::BLACK,
        )?;
        canvas.draw(&bg, DrawParam::default());

        // Draw game title (split into main title and subtitle)
        let mut main_title = Text::new("Crab Rustler");
        main_title.set_scale(112.0);
        let main_title_width = main_title.measure(ctx)?.x;
        let main_title_height = main_title.measure(ctx)?.y;

        let candidate_subtitles = [
            "Even the smallest claw can make big waves when we dance together.",
            "A lone crab scuttles, but many crabs make a rave.",
            "When crabs move as one, the ocean listens.",
            "Shiny lights bring crabs together, but the beat keeps them close.",
            "Follow your light, and you’ll find your clawsome crew.",
            "No crab too small, no groove too deep.",
            "One claw can’t clap, but two can drop the beat.",
            "The tide brings change, but crabs rave on.",
            "It takes many shells to build a real party.",
            "Crabs that groove together, grow together.",
        ];
        let fragment = candidate_subtitles
            .choose(&mut rand::rng())
            .unwrap()
            .to_string();
        let mut subtitle = Text::new(fragment);
        subtitle.set_scale(38.0);
        let subtitle_width = subtitle.measure(ctx)?.x;
        let _subtitle_height = subtitle.measure(ctx)?.y;

        // Draw shadow for main title
        canvas.draw(
            &main_title,
            DrawParam::default()
                .dest(Vec2::new(
                    (width - main_title_width) / 2.0 + 8.0,
                    (height - main_title_height) / 4.0 + 8.0,
                ))
                .color(Color::from_rgba(0, 0, 0, 180))
                .rotation(0.05),
        );

        // Draw main title with a wavy color effect
        for (i, ch) in "Crab Rustler".chars().enumerate() {
            let frag = ggez::graphics::TextFragment::new(ch).scale(112.0);
            let ch_text = Text::new(frag);
            let x = (width - main_title_width) / 2.0 + i as f32 * 60.0;
            let y = (height - main_title_height) / 4.0 + (i as f32 * 0.5).sin() * 16.0;

            let color = Color::from_rgb(
                220 + ((i as f32 * 0.7).sin() * 35.0) as u8,
                80 + ((i as f32 * 1.3).cos() * 140.0) as u8,
                255 - (i as u8 * 7),
            );
            canvas.draw(
                &ch_text,
                DrawParam::default()
                    .dest(Vec2::new(x, y))
                    .color(color)
                    .rotation((i as f32 * 0.1).sin() * 0.08),
            );
        }

        // Draw subtitle centered below the main title
        canvas.draw(
            &subtitle,
            DrawParam::default()
                .dest(Vec2::new(
                    (width - subtitle_width) / 2.0,
                    (height - main_title_height) / 4.0 + main_title_height + 16.0,
                ))
                .color(Color::from_rgb(255, 255, 255)),
        );

        // Draw instructions text centered
        let text = Text::new(
            "Catch all the crabs quickly!\n\nUse the arrow keys to move.\n\nPress Space or Enter to start.",
        );
        let text_width = text.measure(ctx)?.x;
        let text_height = text.measure(ctx)?.y;
        canvas.draw(
            &text,
            DrawParam::default()
                .dest(Vec2::new(
                    (width - text_width) / 2.0,
                    (height - text_height) / 2.0 + 100.0,
                ))
                .color(Color::from_rgb(255, 255, 0)),
        );
        Ok(())
    }

    fn draw_game(
        &self,
        ctx: &mut Context,
        canvas: &mut Canvas,
        width: f32,
        height: f32,
    ) -> GameResult {
        // Draw grass background using the shader.
        draw_grass(
            ctx,
            canvas,
            width,
            height,
            &self.texture,
            &self.shader,
            self.time_elapsed,
        )?;

        // Calculate flashlight direction from player to mouse.
        if self.flashlight.on {
            let flashlight_dir = (self.mouse_pos - self.player_pos).normalize_or_zero();
            draw_flashlight(
                ctx,
                canvas,
                self.player_pos,
                flashlight_dir,
                self.time_since_catch,
                &self.flashlight,
            )?;
        }
        draw_rustler(ctx, canvas, self.player_pos)?;
        self.draw_crabs_with_shake(ctx, canvas)?;
        let text = Text::new(format!("Crabs caught: {}", self.score));
        canvas.draw(
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
        let max_cooldown = 0.08;
        let boost_ratio = (self.boost_timer / max_boost).clamp(0.0, 1.0);
        let cooldown_ratio = (self.boost_cooldown / max_cooldown).clamp(0.0, 1.0);

        // Draw background bar
        let bg_bar = Mesh::new_rectangle(
            ctx,
            ggez::graphics::DrawMode::fill(),
            Rect::new(bar_x, bar_y, bar_width, bar_height),
            Color::from_rgb(40, 40, 40),
        )?;
        canvas.draw(&bg_bar, DrawParam::default());

        // Draw boost timer (yellow)
        let r = ((max_boost - self.boost_timer) / max_boost).clamp(0.0, 1.0);
        if r > 0.0 {
            let boost_bar = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::fill(),
                Rect::new(bar_x, bar_y, bar_width * r, bar_height),
                Color::from_rgb(255, 220, 40),
            )?;
            canvas.draw(&boost_bar, DrawParam::default());
        }

        // Draw cooldown (red, overlays boost)
        if cooldown_ratio > 0.0 {
            let cooldown_bar = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::fill(),
                Rect::new(bar_x, bar_y, bar_width * cooldown_ratio, bar_height),
                Color::from_rgb(220, 60, 60),
            )?;
            canvas.draw(&cooldown_bar, DrawParam::default());
        }

        // Draw stamina bar border
        let border = Mesh::new_rectangle(
            ctx,
            ggez::graphics::DrawMode::stroke(2.0),
            Rect::new(bar_x, bar_y, bar_width, bar_height),
            Color::from_rgb(255, 255, 255),
        )?;
        canvas.draw(&border, DrawParam::default());

        // Draw label
        let label = Text::new("Stamina (Space)");
        canvas.draw(
            &label,
            DrawParam::default()
                .dest(Vec2::new(bar_x, bar_y - 22.0))
                .color(Color::from_rgb(255, 255, 255)),
        );

        // Show current level at the bottom center.
        if self.level_title_timer == 0.0 {
            let mut level_label = Text::new(&self.level_title);
            level_label.set_scale(32.0);
            let label_width = level_label.measure(ctx)?.x;
            let label_height = level_label.measure(ctx)?.y;
            canvas.draw(
                &level_label,
                DrawParam::default()
                    .dest(Vec2::new(
                        (width - label_width) / 2.0,
                        height - label_height - 18.0,
                    ))
                    .color(Color::from_rgba(220, 220, 220, 120)), // subtle, monochrome, semi-transparent
            );
        }

        if self.debug_mode {
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
            canvas.draw(
                &debug_text,
                DrawParam::default()
                    .dest(Vec2::new(10.0, 80.0))
                    .color(Color::from_rgb(255, 100, 100)),
            );
        }

        if self.level_title_timer > 0.0 {
            // Draw a simple geometric monochromatic level title
            let mut title = Text::new(&self.level_title);
            title.set_scale(96.0);
            let title_width = title.measure(ctx)?.x;
            let title_height = title.measure(ctx)?.y;

            // Draw a centered rectangle background for the title
            let rect_x = (width - title_width) / 2.0 - 32.0;
            let rect_y = (height - title_height) / 2.0 - 16.0;
            let rect_w = title_width + 64.0;
            let rect_h = title_height + 32.0;
            let bg_rect = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::fill(),
                Rect::new(rect_x, rect_y, rect_w, rect_h),
                Color::from_rgb(30, 30, 30),
            )?;
            canvas.draw(&bg_rect, DrawParam::default());

            // Draw a white border around the rectangle
            let border_rect = Mesh::new_rectangle(
                ctx,
                ggez::graphics::DrawMode::stroke(3.0),
                Rect::new(rect_x, rect_y, rect_w, rect_h),
                Color::from_rgb(220, 220, 220),
            )?;
            canvas.draw(&border_rect, DrawParam::default());

            // Draw the title text centered in the rectangle, monochrome white
            canvas.draw(
                &title,
                DrawParam::default()
                    .dest(Vec2::new(
                        (width - title_width) / 2.0,
                        (height - title_height) / 2.0,
                    ))
                    .color(Color::from_rgb(240, 240, 240)),
            );
        }
        return Ok(());
    }

    fn draw_crabs_with_shake(&self, ctx: &mut Context, canvas: &mut Canvas) -> GameResult {
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
                draw_crab(ctx, canvas, crab)?;
            }
        }
        Ok(())
    }

    fn draw_game_over_screen(&self, ctx: &mut Context, canvas: &mut Canvas) -> GameResult {
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
        canvas.draw(&bg_box, DrawParam::default());
        let text = Text::new(format!(
            "Game Over!\nTime: {:.2} seconds\nPress Esc to quit.\n\nPress Space or Enter to try again.",
            self.time_elapsed
        ));
        canvas.draw(
            &text,
            DrawParam::default()
                .dest(Vec2::new(370.0, 400.0))
                .color(Color::WHITE),
        );
        Ok(())
    }

    fn draw_upgrade_screen(&self, ctx: &mut Context, canvas: &mut Canvas) -> GameResult {
        let box_width = 600.0;
        let box_height = 260.0;
        let box_x = 340.0;
        let box_y = 340.0;
        let bg_box = Mesh::new_rectangle(
            ctx,
            ggez::graphics::DrawMode::fill(),
            Rect::new(box_x, box_y, box_width, box_height),
            Color::from_rgba(40, 80, 40, 220),
        )?;
        canvas.draw(&bg_box, DrawParam::default());
        let text = Text::new(
            "Upgrade Time!\nChoose an upgrade:\n1. Wider flashlight cone\n2. Longer flashlight range\n3. Laser level up\nPress 1, 2, or 3 to select.",
        );
        canvas.draw(
            &text,
            DrawParam::default()
                .dest(Vec2::new(370.0, 370.0))
                .color(Color::from_rgb(255, 255, 255)),
        );
        Ok(())
    }

    fn apply_upgrade(&mut self, choice: u8) {
        match choice {
            1 => self.flashlight.cone_upgrade += 0.25,  // Wider cone
            2 => self.flashlight.range_upgrade += 60.0, // Longer range
            3 => self.flashlight.laser_level += 1,      // Laser level up
            _ => {}
        }
        self.pending_upgrade = false;
    }
}

impl EventHandler for MainState {
    fn update(&mut self, ctx: &mut Context) -> GameResult {
        if self.show_instructions || self.game_over || self.pending_upgrade {
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

        if self.level_title_timer > 0.0 {
            self.level_title_timer -= dt;
            if self.level_title_timer < 0.0 {
                self.level_title_timer = 0.0;
            }
        }

        let width = ctx.gfx.window().inner_size().width as f32;
        let height = ctx.gfx.window().inner_size().height as f32;
        let area = (width, height);
        handle_player_movement(self, ctx, dt, SPEED, width, height);
        self.handle_crab_catching(ctx);
        self.update_crabs(dt, area);

        // Game over if number of crabs reaches 100.
        if self.crabs.len() >= 100 {
            self.game_over = true;
            return Ok(());
        }

        self.pattern_timer -= dt;
        if self.crabs.iter().all(|c| c.caught) || self.pattern_timer <= 0.0 {
            self.advance_pattern();
        }
        Ok(())
    }

    fn draw(&mut self, ctx: &mut Context) -> GameResult {
        let width = self.width;
        let height = self.height;

        // Render to a virtual-resolution canvas
        let mut canvas = Canvas::from_frame(ctx, Color::from_rgb(100, 200, 100));
        canvas.set_screen_coordinates(Rect::new(0.0, 0.0, width, height));

        canvas.set_blend_mode(BlendMode::ALPHA);
        canvas.set_sampler(Sampler::nearest_clamp());

        if self.show_instructions {
            self.draw_instructions_screen(ctx, &mut canvas, width, height)?;
            canvas.finish(ctx)?;
            return Ok(());
        }

        if self.pending_upgrade {
            self.draw_upgrade_screen(ctx, &mut canvas)?;
            canvas.finish(ctx)?;
            return Ok(());
        }
        if !self.game_over {
            self.draw_game(ctx, &mut canvas, width, height)?;
        } else {
            self.draw_game_over_screen(ctx, &mut canvas)?;
        }
        canvas.finish(ctx)?;
        Ok(())
    }

    fn key_down_event(&mut self, ctx: &mut Context, input: KeyInput, _repeat: bool) -> GameResult {
        if self.pending_upgrade {
            if let Some(key) = input.keycode {
                match key {
                    KeyCode::Key1 => self.apply_upgrade(1),
                    KeyCode::Key2 => self.apply_upgrade(2),
                    KeyCode::Key3 => self.apply_upgrade(3),
                    _ => {}
                }
            }
            return Ok(());
        }
        if let Some(key) = input.keycode {
            if key == KeyCode::F {
                self.flashlight.on = !self.flashlight.on;
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
        let scale_x = window_size.width as f32 / self.width;
        let scale_y = window_size.height as f32 / self.height;
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
