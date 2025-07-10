use ggez::glam::Vec2;
use ggez::graphics::{self, Canvas, Color, DrawMode, DrawParam, Mesh, Rect, Text};
use ggez::Context;

use crate::{Crab, MainState, CRAB_SIZE, PLAYER_SIZE};

pub fn draw_grass(ctx: &mut Context, canvas: &mut Canvas) -> ggez::GameResult {
    use rand::Rng;
    let mut rng = rand::thread_rng();
    for _ in 0..80 {
        let x = rng.gen_range(0.0..800.0);
        let y = rng.gen_range(0.0..600.0);
        let w = rng.gen_range(20.0..60.0);
        let h = rng.gen_range(8.0..20.0);
        let color = Color::from_rgba(
            rng.gen_range(60..120),
            rng.gen_range(160..220),
            rng.gen_range(60..120),
            60,
        );
        let ellipse = graphics::Mesh::new_ellipse(ctx, DrawMode::fill(), [x, y], w, h, 0.5, color)?;
        canvas.draw(&ellipse, DrawParam::default());
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

pub fn draw_crab(ctx: &mut Context, canvas: &mut Canvas, crab: &Crab) -> ggez::GameResult {
    // Crab body
    let crab_body = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [0.0, 0.0],
        CRAB_SIZE / 2.0,
        0.5,
        Color::from_rgb(255, 100, 100),
    )?;
    // Crab legs (6 lines)
    let mut leg_meshes = Vec::new();
    let leg_len = CRAB_SIZE * 0.7;
    let leg_color = Color::from_rgb(200, 50, 50);
    for i in 0..6 {
        let angle = std::f32::consts::PI * (0.25 + i as f32 / 6.0);
        let x1 = (CRAB_SIZE / 2.0) * angle.cos();
        let y1 = (CRAB_SIZE / 2.0) * angle.sin();
        let x2 = (CRAB_SIZE / 2.0 + leg_len) * angle.cos();
        let y2 = (CRAB_SIZE / 2.0 + leg_len) * angle.sin();
        let leg = Mesh::new_line(ctx, &[[x1, y1], [x2, y2]], 2.0, leg_color)?;
        leg_meshes.push(leg);
    }
    // Crab claws (small circles)
    let claw_offset = CRAB_SIZE * 0.7;
    let claw_radius = CRAB_SIZE * 0.18;
    let left_claw = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [-(claw_offset), -(claw_offset * 0.3)],
        claw_radius,
        0.5,
        Color::from_rgb(255, 120, 120),
    )?;
    let right_claw = Mesh::new_circle(
        ctx,
        DrawMode::fill(),
        [claw_offset, -(claw_offset * 0.3)],
        claw_radius,
        0.5,
        Color::from_rgb(255, 120, 120),
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
) -> ggez::GameResult {
    use ggez::glam::Vec2 as GVec2;
    use ggez::graphics::{DrawMode, DrawParam, Mesh};
    // Draw a dark overlay
    let darkness = Mesh::new_rectangle(
        ctx,
        DrawMode::fill(),
        Rect::new(0.0, 0.0, 800.0, 600.0),
        Color::from_rgba(0, 0, 0, 200),
    )?;
    canvas.draw(&darkness, DrawParam::default());

    // Draw a cone-shaped flashlight (fan of triangles)
    let flashlight_len = 220.0;
    let flashlight_width = 120.0;
    let segments = 32;
    let mut points = vec![GVec2::new(
        player_pos.x + PLAYER_SIZE / 2.0,
        player_pos.y + PLAYER_SIZE / 2.0,
    )];
    let angle = dir.y.atan2(dir.x);
    for i in 0..=segments {
        let theta = angle - 0.35 + 0.7 * (i as f32 / segments as f32);
        let x = player_pos.x + PLAYER_SIZE / 2.0 + flashlight_len * theta.cos();
        let y = player_pos.y + PLAYER_SIZE / 2.0 + flashlight_len * theta.sin();
        points.push(GVec2::new(
            x + flashlight_width * (theta - angle).sin(),
            y - flashlight_width * (theta - angle).cos(),
        ));
    }
    let flashlight = Mesh::new_polygon(
        ctx,
        DrawMode::fill(),
        &points,
        Color::from_rgba(255, 255, 200, 8), // very faint yellowish
    )?;
    canvas.draw(&flashlight, DrawParam::default());
    Ok(())
}
