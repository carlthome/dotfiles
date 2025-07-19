use crate::enemies::EnemyCrab;
use crate::{CRAB_SIZE, Flashlight, PLAYER_SIZE};
use crevice::std140::AsStd140;
use ggez::Context;
use ggez::glam::Vec2;
use ggez::graphics::{Canvas, Color, DrawMode, DrawParam, Mesh, Rect, Shader, ShaderParamsBuilder};

#[derive(Copy, Clone, Debug, AsStd140)]
pub struct ResolutionUniform {
    pub width: f32,
    pub height: f32,
}

pub fn draw_grass(
    ctx: &mut Context,
    canvas: &mut Canvas,
    width: f32,
    height: f32,
    shader: &Shader,
) -> ggez::GameResult {
    let solid_bg = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(0.0, 0.0, width, height),
        Color::from_rgb(0, 100, 0),
    )?;
    canvas.draw(&solid_bg, DrawParam::default());

    // Draw a full-screen quad using the grass shader.
    let params = ShaderParamsBuilder::new(&ResolutionUniform { width, height }).build(ctx);
    canvas.set_shader_params(&params);
    canvas.set_shader(shader);

    let quad = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(0.0, 0.0, width, height),
        Color::RED,
    )?;
    canvas.draw(&quad, DrawParam::default());
    canvas.set_default_shader();
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
    time_since_catch: f32,
    flashlight: &Flashlight,
) -> ggez::GameResult {
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

    // Flashlight parameters
    let laser_level = flashlight.laser_level;
    let cone_angle = flashlight.cone_upgrade;
    let range = flashlight.range_upgrade;

    // Draw a cone-shaped flashlight (sector) with bloom/gradient
    let flashlight_len = range.max(80.0);
    let spread = cone_angle.max(0.15);
    let center = Vec2::new(
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
            points.push(Vec2::new(x, y));
        }
        let flashlight = Mesh::new_polygon(ctx, DrawMode::fill(), &points, color)?;
        canvas.draw(&flashlight, DrawParam::default());
    }
    // Crab Techno Rave: draw laser beams if upgraded
    if laser_level > 0 {
        let laser_colors = [
            Color::from_rgb(255, 0, 255),
            Color::from_rgb(0, 255, 255),
            Color::from_rgb(255, 255, 0),
            Color::from_rgb(0, 255, 0),
            Color::from_rgb(255, 0, 0),
        ];
        let num_lasers = 2 + laser_level * 2;
        let laser_len = flashlight_len * (1.2 + 0.2 * laser_level as f32);
        for i in 0..num_lasers {
            let t = i as f32 / num_lasers as f32;
            let laser_angle = angle - spread / 2.0 + spread * t;
            let color = laser_colors[(i as usize) % laser_colors.len()];
            let end = center + Vec2::new(laser_angle.cos(), laser_angle.sin()) * laser_len;
            let laser = Mesh::new_line(ctx, &[center, end], 6.0 + 2.0 * laser_level as f32, color)?;
            canvas.draw(&laser, DrawParam::default());
        }
    }
    Ok(())
}
