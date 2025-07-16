use ggez::glam::Vec2;

#[derive(Clone, Copy, Debug)]
pub enum CrabType {
    Normal,
    Fast,
    Big,
    Sneaky,
}

impl CrabType {
    pub fn random(rng: &mut impl rand::Rng) -> Self {
        use CrabType::*;
        match rng.random_range(0..4) {
            0 => Normal,
            1 => Fast,
            2 => Big,
            _ => Sneaky,
        }
    }
    pub fn speed_range(&self) -> std::ops::Range<f32> {
        match self {
            CrabType::Normal => 30.0..70.0,
            CrabType::Fast => 60.0..120.0,
            CrabType::Big => 20.0..40.0,
            CrabType::Sneaky => 40.0..80.0,
        }
    }
    pub fn scale_range(&self) -> std::ops::RangeInclusive<f32> {
        match self {
            CrabType::Normal => 0.28..=0.48,
            CrabType::Fast => 0.24..=0.36,
            CrabType::Big => 0.50..=0.80,
            CrabType::Sneaky => 0.30..=0.40,
        }
    }
}

#[derive(Clone, Debug)]
pub struct EnemyCrab {
    pub pos: Vec2,
    pub vel: Vec2,
    pub speed: f32,
    pub caught: bool,
    pub scale: f32,
    pub spawn_time: f32,
    pub crab_type: CrabType,
    pub spooked_timer: f32,
}
