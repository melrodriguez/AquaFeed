struct LevelConfig {
    let aquarium: Int
    let level: Int
    let spawnRate: Int
    let aliens: [AlienType]
    let eggPrice: Int
    let prize: PetType
    let menuButton: [MenuButtonType]
}

struct LevelConfigs {
    static let level1 = LevelConfig(
        aquarium: 1,
        level: 1,
        spawnRate: 0,
        aliens: [],
        eggPrice: 150,
        prize: PetType.stinky,
        menuButton: [MenuButtonType.buyGuppy, MenuButtonType.buyEgg]
    )
    
    static let level2 = LevelConfig(
        aquarium: 1,
        level: 2,
        spawnRate: 60,
        aliens: [AlienType.sylvester],
        eggPrice: 500,
        prize: PetType.niko,
        menuButton: [
            MenuButtonType.buyGuppy,
            MenuButtonType.buyFoodQualityUpgrade,
            MenuButtonType.buyFoodLimitIncrease,
            MenuButtonType.buyEgg
        ]
    )

    static let level3 = LevelConfig(
        aquarium: 1,
        level: 3,
        spawnRate: 45,
        aliens: [AlienType.sylvester],
        eggPrice: 2000,
        prize: PetType.itchy,
        menuButton: [
            MenuButtonType.buyGuppy,
            MenuButtonType.buyFoodQualityUpgrade,
            MenuButtonType.buyFoodLimitIncrease,
            MenuButtonType.buyCarnivore,
            MenuButtonType.buyLaserUpgrade,
            MenuButtonType.buyEgg
        ]
    )
    
    static let level4 = LevelConfig(
        aquarium: 1,
        level: 4,
        spawnRate: 45,
        aliens: [AlienType.balrog],
        eggPrice: 3000,
        prize: PetType.prego,
        menuButton: [
            MenuButtonType.buyGuppy,
            MenuButtonType.buyFoodQualityUpgrade,
            MenuButtonType.buyFoodLimitIncrease,
            MenuButtonType.buyCarnivore,
            MenuButtonType.buyLaserUpgrade,
            MenuButtonType.buyEgg
        ]
    )
    
    static let level5 = LevelConfig(
        aquarium: 1,
        level: 5,
        spawnRate: 45,
        aliens: [AlienType.sylvester, AlienType.balrog],
        eggPrice: 5000,
        prize: PetType.zorf,
        menuButton: [
            MenuButtonType.buyGuppy,
            MenuButtonType.buyFoodQualityUpgrade,
            MenuButtonType.buyFoodLimitIncrease,
            MenuButtonType.buyCarnivore,
            MenuButtonType.buyLaserUpgrade,
            MenuButtonType.buyEgg
        ]
    )
}

extension LevelConfig {
    var next: LevelConfig? {
        switch self.level {
        case 1: return LevelConfigs.level2
        case 2: return LevelConfigs.level3
        case 3: return LevelConfigs.level4
        case 4: return LevelConfigs.level5
        default: return nil
        }
    }
    
    static func getLevel(_ level: Int) -> LevelConfig? {
        switch level {
        case 1: return LevelConfigs.level1
        case 2: return LevelConfigs.level2
        case 3: return LevelConfigs.level3
        case 4: return LevelConfigs.level4
        case 5: return LevelConfigs.level5
        default: return nil
        }
    }
}
