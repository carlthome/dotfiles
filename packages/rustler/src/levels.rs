use crate::spawnings::SpawnPattern;

pub struct LevelPattern {
    pub pattern: SpawnPattern,
    pub count: usize,
    pub duration: f32,
}

pub struct Level {
    pub title: String,
    pub description: String,
    pub difficulty: usize,
    pub patterns: Vec<LevelPattern>,
}

pub fn get_levels() -> Vec<Level> {
    vec![
        Level {
            title: "Rustler's First Ride".to_string(),
            description: "A beginner's level to get you started with the Rustler game.".to_string(),
            difficulty: 0,
            patterns: vec![LevelPattern {
                pattern: SpawnPattern::SingleRandom,
                count: 3,
                duration: 10.0,
            }],
        },
        Level {
            title: "Rustler's Challenge".to_string(),
            description: "A challenging level with multiple spawn patterns.".to_string(),
            difficulty: 2,
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
            title: "Rustler's Gauntlet".to_string(),
            description: "A gauntlet of spawn patterns to test your skills.".to_string(),
            difficulty: 3,
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
