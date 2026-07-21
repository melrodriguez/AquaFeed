import SpriteKit

class SpawnManager {
    
    weak var scene: LevelScene?
    
    init(scene: LevelScene) {
        self.scene = scene
    }
    
    func spawnGuppy() {
        guard let scene = scene else { return }
        
        let guppy = Guppy(
            swimTextures: FishTextures.guppySmallSwim,
            turnTextures: FishTextures.guppySmallTurn,
            eatTextures: FishTextures.guppySmallEat,
            deadTextures: FishTextures.guppySmallDead,
            scale: 2.0,
            swimSpeed: GuppySize.small.swimSpeed,
            hunger: 25,
            spawnCoinTime: 8
        )
        
        guppy.position = getSpawnPoint(for: guppy.size)
        guppy.physicsBody = SKPhysicsBody(circleOfRadius: guppy.size.width / 2)
        guppy.physicsBody?.affectedByGravity = false
        guppy.physicsBody?.isDynamic = true
        guppy.physicsBody?.categoryBitMask = PhysicsCategory.guppy
        guppy.physicsBody?.contactTestBitMask = PhysicsCategory.food
        guppy.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        GameState.shared.addGuppy(guppy)
        scene.addChild(guppy)
        guppy.startState()
    }
    
    func spawnCarnivore() {
        guard let scene = scene else { return }
        
        let carnivore = Carnivore(
            swimTextures: FishTextures.carnivoreSwim,
            turnTextures: FishTextures.carnivoreTurn,
            eatTextures: FishTextures.carnivoreEat,
            deadTextures: FishTextures.carnivoreDead,
            scale: 2.0,
            swimSpeed: 170,
            hunger: 60,
            spawnCoinTime: 30,
            moneyDrop: MoneyType.diamond,
            swimFoodSpeedMultiplier: 1.5
        )
       
        carnivore.position = getSpawnPoint(for: carnivore.size)
        carnivore.physicsBody = SKPhysicsBody(circleOfRadius: carnivore.size.width / 2)
        carnivore.physicsBody?.affectedByGravity = false
        carnivore.physicsBody?.isDynamic = true
        carnivore.physicsBody?.categoryBitMask = PhysicsCategory.carnivore
        carnivore.physicsBody?.contactTestBitMask = PhysicsCategory.guppy
        carnivore.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        GameState.shared.addCarnivore(carnivore)
        scene.addChild(carnivore)
        carnivore.startState()
    }
    
    func spawnAlien(alienType: AlienType) {
        guard let scene = scene else { return }
        
        let alien = Alien(alienType: alienType)
        
        alien.position = getSpawnPoint(for: alien.size)
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.width / 2)
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = PhysicsCategory.alien
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.guppy | PhysicsCategory.carnivore
        alien.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        GameState.shared.addAlien(alien)
        scene.addChild(alien)
    }
    
    func spawnFood(at position: CGPoint, quality: FoodQuality) {
        guard let scene = scene else { return }
        
        let food = Food(quality: quality)
        food.position = position
        food.name = "food"
        
        food.physicsBody = SKPhysicsBody(rectangleOf: food.size)
        food.physicsBody?.affectedByGravity = true
        food.physicsBody?.linearDamping = 2.0
        food.physicsBody?.angularDamping = 2.0
        food.physicsBody?.mass = 0.2
        food.physicsBody?.categoryBitMask = PhysicsCategory.food
        food.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        food.physicsBody?.collisionBitMask = PhysicsCategory.ground
        
        GameState.shared.addFood(food)
        scene.addChild(food)
    }
    
    func spawnMoney(at position: CGPoint, type: MoneyType) {
        guard let scene = scene else { return }
        
        let money = Money(type: type)
    
        money.position = position
        money.name = "money"
        
        money.physicsBody = SKPhysicsBody(rectangleOf: money.size)
        money.physicsBody?.affectedByGravity = true
        money.physicsBody?.linearDamping = 2.0
        money.physicsBody?.angularDamping = 2.0
        money.physicsBody?.mass = 0.2
        money.physicsBody?.categoryBitMask = PhysicsCategory.money
        money.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        money.physicsBody?.collisionBitMask = PhysicsCategory.ground

        GameState.shared.addMoney(money)
        scene.addChild(money)
    }

    private func getSpawnPoint(for spriteSize: CGSize) -> CGPoint {
        guard let scene = scene else { return .zero }
        
        let minY = (scene.size.height - (scene.size.height * 0.70)) / 2
        let maxY = scene.size.height - (scene.size.height * (0.20))
        let adjustedMaxY = maxY - (spriteSize.height / 2)
        
        let randomX = CGFloat.random(in: 50...scene.size.width - 50)
        let randomY = CGFloat.random(in: minY...adjustedMaxY)
        
        return CGPoint(x: randomX, y: randomY)
    }

//    private func randomSpawnPoint(for fishSize: CGSize) -> CGPoint {
//        let adjustedMaxY = maxY - (fishSize.height / 2)
//        
//        let randomX = CGFloat.random(in: 50...size.width - 50)
//        let randomY = CGFloat.random(in: minY...adjustedMaxY)
//        
//        return CGPoint(x: randomX, y: randomY)
//    }
}
