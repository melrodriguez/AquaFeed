struct LevelConfig {
    let aquarium: Int
    let level: Int
    let spawnRate: Double
    let aliens: [AlienType]
    let eggPrice: Int
    let prize: PetType
}

struct Levels {
    
    static let level1 = LevelConfig(
        aquarium: 1,
        level: 1,
        spawnRate: 0.0,
        aliens: [],
        eggPrice: 150,
        prize: PetType.itchy
    )
    
//    static let levelTest = LevelConfig(
//        aquarium: 1,
//        level: 100,
//        eggPrice: 150
//    )
}
