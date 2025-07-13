use ggez::Context;
use ggez::glam::Vec2;
use ggez::graphics::{self, Canvas, Color, DrawMode, DrawParam, Mesh, Rect};

use crate::enemies::EnemyCrab;
use crate::{CRAB_SIZE, PLAYER_SIZE};

pub fn draw_grass(
    ctx: &mut Context,
    canvas: &mut Canvas,
    width: f32,
    height: f32,
) -> ggez::GameResult {
    use rand::Rng;
    let mut rng = rand::rng();
    let time = ctx.time.time_since_start().as_secs_f32();

    // Draw a soft grassy background.
    let grass_color = Color::from_rgba(80, 200, 120, 100);
    let bg = graphics::Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(0.0, 0.0, width, height),
        grass_color,
    )?;
    canvas.draw(&bg, DrawParam::default());

    // Parameters for grass blades
    let num_blades = (width / 6.0) as usize; // density
    let base_y = height - 8.0;
    let blade_min_h = height * 0.12;
    let blade_max_h = height * 0.28;
    let blade_min_w = 1.2;
    let blade_max_w = 2.8;
    let wind_speed = 1.2;
    let wind_strength = 16.0;

    for i in 0..num_blades {
        let x = i as f32 * (width / num_blades as f32) + rng.random_range(-2.0..2.0);
        let blade_height = rng.random_range(blade_min_h..blade_max_h);
        let blade_width = rng.random_range(blade_min_w..blade_max_w);
        let base_color = [
            rng.random_range(60..100),
            rng.random_range(160..220),
            rng.random_range(60..100),
        ];
        let tip_color = [
            rng.random_range(120..180),
            rng.random_range(220..255),
            rng.random_range(120..180),
        ];
        let t = i as f32 / num_blades as f32;
        // Animate sway with wind
        let phase = t * 6.0 + rng.random_range(0.0..2.0);
        let sway = (time * wind_speed + phase).sin() * wind_strength * (0.5 + t * 0.5);
        let lean = sway + rng.random_range(-4.0..4.0);

        // Control points for a simple bezier curve (simulate a blade)
        let base = [x, base_y];
        let ctrl = [x + lean * 0.4, base_y - blade_height * 0.5];
        let tip = [x + lean, base_y - blade_height];

        // Draw the blade as a thin, curved polygon (triangle strip)
        let points = vec![
            [base[0] - blade_width * 0.5, base[1]],
            [ctrl[0] - blade_width * 0.2, ctrl[1]],
            [tip[0], tip[1]],
            [ctrl[0] + blade_width * 0.2, ctrl[1]],
            [base[0] + blade_width * 0.5, base[1]],
        ];
        let color = Color::from_rgba(base_color[0], base_color[1], base_color[2], 180);
        let tip_col = Color::from_rgba(tip_color[0], tip_color[1], tip_color[2], 210);
        let mesh = Mesh::new_polygon(ctx, DrawMode::fill(), &points, color)?;
        canvas.draw(&mesh, DrawParam::default());

        // Optionally, draw a highlight along the blade for anime shine
        let highlight = Mesh::new_line(ctx, &[[base[0], base[1]], [tip[0], tip[1]]], 0.7, tip_col)?;
        canvas.draw(&highlight, DrawParam::default());
    }
    Ok(())
}

pub fn draw_rustler(ctx: &mut Context, canvas: &mut Canvas, pos: Vec2) -> ggez::GameResult {
    // Head
    let head = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [PLAYER_SIZE / 2.0, PLAYER_SIZE / 3.0],
        PLAYER_SIZE / 4.0,
        0.5,
        Color::from_rgb(160, 82, 45),
    )?;
    canvas.draw(&head, DrawParam::default().dest(pos));

    // Body
    let body = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(
            PLAYER_SIZE / 2.5,
            PLAYER_SIZE / 2.0,
            PLAYER_SIZE / 5.0,
            PLAYER_SIZE / 2.0,
        ),
        Color::from_rgb(139, 69, 19),
    )?;
    canvas.draw(&body, DrawParam::default().dest(pos));

    // Hat brim
    let hat_brim = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(
            PLAYER_SIZE / 2.0 - PLAYER_SIZE / 4.0,
            PLAYER_SIZE / 4.5,
            PLAYER_SIZE / 2.0,
            PLAYER_SIZE / 10.0,
        ),
        Color::from_rgb(80, 40, 20),
    )?;
    canvas.draw(&hat_brim, DrawParam::default().dest(pos));

    // Hat top
    let hat_top = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(
            PLAYER_SIZE / 2.0 - PLAYER_SIZE / 8.0,
            PLAYER_SIZE / 7.0,
            PLAYER_SIZE / 4.0,
            PLAYER_SIZE / 6.0,
        ),
        Color::from_rgb(80, 40, 20),
    )?;
    canvas.draw(&hat_top, DrawParam::default().dest(pos));

    Ok(())
}

pub fn draw_crab(ctx: &mut Context, canvas: &mut Canvas, crab: &EnemyCrab) -> ggez::GameResult {
    // Grow size with age
    let grow_t = (crab.spawn_time / 10.0).min(1.0);
    let size = CRAB_SIZE * (0.6 + 0.4 * grow_t) * crab.scale;

    // Color: more red as crab ages, and different color for type
    let t = (crab.spawn_time / 10.0).min(1.0);
    let (r, g, b) = match crab.crab_type {
        crate::enemies::CrabType::Normal => (
            (255.0 * (0.6 + 0.4 * t)),
            (100.0 * (1.0 - t)),
            (100.0 * (1.0 - t)),
        ),
        crate::enemies::CrabType::Fast => (255.0, 180.0 * (1.0 - t), 40.0),
        crate::enemies::CrabType::Big => (180.0, 60.0, 180.0 * (1.0 - t)),
        crate::enemies::CrabType::Sneaky => (120.0, 220.0, 220.0),
    };
    let crab_color = Color::from_rgb(r as u8, g as u8, b as u8);

    // Crab body
    let crab_body = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [0.0, 0.0],
        size / 2.0,
        0.5,
        crab_color,
    )?;

    // Crab legs (6 lines)
    let mut leg_meshes = Vec::new();
    let leg_len = size * 0.7;
    let leg_color = Color::from_rgb(200, 50, 50);
    for i in 0..6 {
        let base_angle = std::f32::consts::PI * (0.25 + i as f32 / 6.0);
        let time = ctx.time.time_since_start().as_secs_f32();
        let phase = (crab.pos.x + crab.pos.y) * 0.05;
        let wiggle_speed = 2.0 + crab.speed * 0.08; // scale with crab speed
        let wiggle = (time * wiggle_speed + phase + i as f32).sin() * 0.18;
        let angle = base_angle + wiggle;
        let x1 = (size / 2.0) * angle.cos();
        let y1 = (size / 2.0) * angle.sin();
        let x2 = (size / 2.0 + leg_len) * angle.cos();
        let y2 = (size / 2.0 + leg_len) * angle.sin();
        let leg = Mesh::new_line(ctx, &[[x1, y1], [x2, y2]], 2.0, leg_color)?;
        leg_meshes.push(leg);
    }

    // Crab claws (small circles)
    let claw_offset = size * 0.7;
    let claw_radius = size * 0.18;
    let left_claw = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [-(claw_offset), -(claw_offset * 0.3)],
        claw_radius,
        0.5,
        crab_color,
    )?;
    let right_claw = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [claw_offset, -(claw_offset * 0.3)],
        claw_radius,
        0.5,
        crab_color,
    )?;

    // Draw all parts at crab.pos
    canvas.draw(&crab_body, DrawParam::default().dest(crab.pos));
    for leg in &leg_meshes {
        canvas.draw(leg, DrawParam::default().dest(crab.pos));
    }
    canvas.draw(&left_claw, DrawParam::default().dest(crab.pos));
    canvas.draw(&right_claw, DrawParam::default().dest(crab.pos));

    Ok(())
}

pub fn draw_flashlight(
    ctx: &mut Context,
    canvas: &mut Canvas,
    player_pos: Vec2,
    dir: Vec2,
    width: f32,
    height: f32,
    time_since_catch: f32,
) -> ggez::GameResult {
    use ggez::glam::Vec2 as GVec2;
    use ggez::graphics::{DrawMode, DrawParam, Mesh};

    let darkness = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(0.0, 0.0, width, height),
        Color::from_rgba(0, 0, 0, 230),
    )?;
    canvas.draw(&darkness, DrawParam::default());

    // Flicker logic
    let time = ctx.time.time_since_start().as_secs_f32();
    let base_freq = 4.0;
    let max_freq = 18.0;
    let freq = base_freq + (max_freq - base_freq) * (time_since_catch / 12.0).min(1.0);
    let base_alpha = 24.0;
    let max_alpha = 90.0;
    let flicker_strength = (time_since_catch / 3.0).min(2.0);
    let flicker = (time * freq + (player_pos.x + player_pos.y) * 0.01)
        .sin()
        .abs();
    let alpha = base_alpha + (max_alpha - base_alpha) * flicker * flicker_strength;

    // Draw a cone-shaped flashlight (sector) with bloom/gradient
    let flashlight_len = 220.0;
    let spread = 0.7;
    let center = GVec2::new(
        player_pos.x + PLAYER_SIZE / 2.0,
        player_pos.y + PLAYER_SIZE / 2.0,
    );
    let angle = dir.y.atan2(dir.x);

    // Parameterized bloom/gradient flashlight
    let min_layers = 1;
    let max_layers = 10;
    let t_catch = (time_since_catch / 5.0).clamp(0.0, 1.0);
    let num_layers =
        (max_layers as f32 - (max_layers as f32 - min_layers as f32) * t_catch).round() as usize;
    let min_scale = 0.7;
    let max_scale = 1.4;
    let min_alpha = 180.0;
    let max_alpha = (alpha * 0.18).max(10.0);
    let min_color = [255.0, 255.0, 255.0];
    let max_color = [255.0, 255.0, 200.0];
    for i in 0..num_layers {
        let t = i as f32 / (num_layers - 1).max(1) as f32;
        let scale = min_scale + (max_scale - min_scale) * t;
        let segs = if i < 2 { 24 } else { 32 };

        // Interpolate color and alpha.
        let r = min_color[0] + (max_color[0] - min_color[0]) * t;
        let g = min_color[1] + (max_color[1] - min_color[1]) * t;
        let b = min_color[2] + (max_color[2] - min_color[2]) * t;
        let a = min_alpha + (max_alpha - min_alpha) * t;
        let color = Color::from_rgba(r as u8, g as u8, b as u8, a as u8);
        let mut points = vec![center];
        for j in 0..=segs {
            let theta = angle - spread / 2.0 + spread * (j as f32 / segs as f32);
            let x = center.x + flashlight_len * scale * theta.cos();
            let y = center.y + flashlight_len * scale * theta.sin();
            points.push(GVec2::new(x, y));
        }
        let flashlight = Mesh::new_polygon(ctx, DrawMode::fill(), &points, color)?;
        canvas.draw(&flashlight, DrawParam::default());
    }
    Ok(())
}
