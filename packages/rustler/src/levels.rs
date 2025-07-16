use crate::spawnings::SpawnPattern;

pub struct LevelPattern {
    pub pattern: SpawnPattern,
    pub count: usize,
    pub duration: f32,
}

pub struct Level {
    pub patterns: Vec<LevelPattern>,
}

pub fn get_levels() -> Vec<Level> {
    vec![
        Level {
            patterns: vec![LevelPattern {
                pattern: SpawnPattern::SingleRandom,
                count: 3,
                duration: 10.0,
            }],
        },
        Level {
            patterns: vec![
                LevelPattern {
                    pattern: SpawnPattern::UniformRandom,
                    count: 5,
                    duration: 8.0,
                },
                LevelPattern {
                    pattern: SpawnPattern::SineWave,
                    count: 7,
                    duration: 10.0,
                },
                LevelPattern {
                    pattern: SpawnPattern::Circle,
                    count: 8,
                    duration: 12.0,
                },
                LevelPattern {
                    pattern: SpawnPattern::Cluster,
                    count: 10,
                    duration: 10.0,
                },
            ],
        },
        Level {
            patterns: vec![
                LevelPattern {
                    pattern: SpawnPattern::Cluster,
                    count: 12,
                    duration: 10.0,
                },
                LevelPattern {
                    pattern: SpawnPattern::SineWave,
                    count: 10,
                    duration: 12.0,
                },
                LevelPattern {
                    pattern: SpawnPattern::Circle,
                    count: 14,
                    duration: 14.0,
                },
            ],
        },
    ]
}
