struct LevelConfig {
    let aquarium: Int
    let level: Int
    let spawnRate: Double
    let aliens: [AlienType]
    let eggPrice: Int
    let prize: PetType
}

struct LevelConfigs {
    
    static let level1 = LevelConfig(
        aquarium: 1,
        level: 1,
        spawnRate: 0.0,
        aliens: [],
        eggPrice: 150,
        prize: PetType.stinky
    )
    
    static let level2 = LevelConfig(
        aquarium: 1,
        level: 2,
        spawnRate: 0.0,
        aliens: [],
        eggPrice: 500,
        prize: PetType.niko
    )

//    static let levelTest = LevelConfig(
//        aquarium: 1,
//        level: 100,
//        eggPrice: 150
//    )
}
