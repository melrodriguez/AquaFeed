//
//  LevelScene.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/1/26.
//

import SpriteKit
import SwiftUI

// TODO: MAYBE MOVE PHYSICS CATEGORY
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let food: UInt32 = 0x1 << 0
    static let guppy: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let money: UInt32 = 0x1 << 3
    static let carnivore: UInt32 = 0x1 << 4
    static let alien: UInt32 = 0x1 << 5
}

let despawnTime = 1.5
let guppyPrice = 100
let carnivorePrice = 1000
let upgradeFoodQualityCost = 200
let increaseFoodLimitCost = 300
let eggLimit = 3
let maxQualityUpgrade = FoodQuality.level3

class LevelScene: SKScene, SKPhysicsContactDelegate {
    var config: LevelConfig!
    var background = SKSpriteNode(imageNamed: "aquarium")
    var menu = SKSpriteNode(imageNamed: "menu")
    var walletLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var eggLabel = SKSpriteNode(imageNamed: "egg_label_00")
    var foodLimitLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
    var buyGuppyButton = SKSpriteNode(imageNamed: "menu_board")
    var buyEggButton = SKSpriteNode(imageNamed: "menu_board")
    var upgradeFoodQuality = SKSpriteNode(imageNamed: "menu_board")
    var increaseFoodLimit = SKSpriteNode(imageNamed: "menu_board")
    var buyCarnivoreButton = SKSpriteNode(imageNamed: "menu_board")
    var foodUpgradeLabel1 = SKSpriteNode(texture: ItemTextures.food1)
    var foodUpgradeLabel2 = SKSpriteNode(texture: ItemTextures.food2)
    var ground = SKNode()
    
    var maxHeight: CGFloat {
        size.height * 0.70
    }
    
    var minY: CGFloat {
        (size.height - maxHeight) / 2
    }
    
    var maxY: CGFloat {
        size.height - (size.height * (0.20))
    }
    
    var groundY: CGFloat {
        (size.height - maxHeight) / 2 - 20
    }
    
    var pauseDuration = 1.0;
    var state = GameState()
    
    var hungerTimer: Timer?

    override func didMove(to view: SKView) {
        // This is just for testing purposes
        if config.level == 100 {
            state.wallet = 4000
        }
        
        setupBackground()
        setupGround()
        setupMenu()
        setupUI()
        startLevel()
        
        // enable collision detection
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if let money = node as? Money {
                state.updateWallet(amount: money.type.value)
                updateWalletLabel()
                money.removeFromParent()
                return
            }
            
            handleNodeTap(node)
            
            // Prevent dropping food when clicking menu
            if let menu = node as? SKSpriteNode,
               menu.name == "menu"
            { return }
        }
        
        // Drop Food
        guard location.y > groundY else { return }
        if state.foodList.count < state.foodLimit {
            if state.wallet >= 5 {
                state.updateWallet(amount: -5)
                spawnFood(at: location)
                updateWalletLabel()
            }
        }
    }
    
    private func handleNodeTap(_ node: SKNode) {
        switch node.name {
        case "buyGuppy":
            buyGuppy()
            
        case "buyEgg":
            buyEgg()
        
        case "upgradeQuality":
            buyFoodQualityUpgrade()
            
        case "increaseFoodLimit":
            buyFoodLimitIncrease()
        
        case "buyCarnivore":
            buyCarnivore()
        
        default:
            break
        }
    }
    
    func buyGuppy() {
        if buyGuppyButton.isHidden { return }
        
        if state.wallet >= guppyPrice {
            state.updateWallet(amount: -guppyPrice)
            spawnGuppy()
            updateWalletLabel()
        }
        return
    }
    
    func buyEgg() {
        if buyEggButton.isHidden { return }
        
        if state.wallet >= config.eggPrice {
            state.updateWallet(amount: -config.eggPrice)
            updateWalletLabel()
            state.increaseEggCount()
            updateEggLabel()
        }
        return
    }
    
    func buyFoodQualityUpgrade() {
        if upgradeFoodQuality.isHidden { return }
        
        if state.foodQuality == maxQualityUpgrade { return }
        
        if state.wallet >= upgradeFoodQualityCost {
            state.updateWallet(amount: -upgradeFoodQualityCost)
            updateWalletLabel()
            state.upgradeFood()
            updateUpgradeFoodLabel()
        }
    }
    
    func buyFoodLimitIncrease() {
        if increaseFoodLimit.isHidden { return }
        
        if state.wallet >= increaseFoodLimitCost {
            state.updateWallet(amount: -increaseFoodLimitCost)
            updateWalletLabel()
            state.increaseFoodLimit()
            updateFoodLimitLabel()
        }
    }
    
    func buyCarnivore() {
        if buyCarnivoreButton.isHidden { return }
        
        if state.wallet >= carnivorePrice {
            state.updateWallet(amount: -carnivorePrice)
            updateWalletLabel()
            spawnCarnivore()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        for guppy in state.guppyList {
            guppy.frameUpdate()
        }
        
        for carnivore in state.carnivoreList {
            carnivore.frameUpdate()
        }
        
        for alien in state.alienList {
            alien.frameUpdate()
        }

        state.removeDeadGuppy()
        state.removeDeadCarnivore()
        state.removeDeadAlien()
        
        // Temporary Game Over Scene
        if state.eggCount == eggLimit {
            guard let view = self.view else { return }
            
            let titleScene = TitleScene(size: size)
            let transition = SKTransition.fade(with: .black, duration: 1)
            view.presentScene(titleScene, transition: transition)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if categories == PhysicsCategory.food | PhysicsCategory.ground {
            guard let food: Food = node(ofType: Food.self, from: contact) else { return }
            
            despawnItem(food, isFood: true)
        } else if categories == PhysicsCategory.food | PhysicsCategory.guppy {
            guard
                let food: Food = node(ofType: Food.self, from: contact),
                let guppy: Guppy = node(ofType: Guppy.self, from: contact)
            else { return
            }
                
            fishFed(food, guppy)
        } else if categories == PhysicsCategory.money | PhysicsCategory.ground {
            guard let money: Money = node(ofType: Money.self, from: contact) else { return }
            
            despawnItem(money, isFood: false)
        }
        else if categories == PhysicsCategory.carnivore | PhysicsCategory.guppy {
            guard
                let guppy: Guppy = node(ofType: Guppy.self, from: contact),
                let carnivore: Carnivore = node(ofType: Carnivore.self, from: contact)
            else { return
            }
            
            if carnivore.state == FishState.seekFood {
                carnivore.animateEat()
                carnivore.hunger += 60
                carnivore.targetFood = nil
                guppy.die(showDieAnimation: false)
            }
        }
        else if categories == PhysicsCategory.alien | PhysicsCategory.guppy ||
                    categories == PhysicsCategory.alien | PhysicsCategory.carnivore {
            guard
                let fish: Fish = node(ofType: Fish.self, from: contact),
                let alien: Alien = node(ofType: Alien.self, from: contact)
            else { return
            }
            
            fish.die(showDieAnimation: false)
            alien.prey = nil
        }
    }
    
    func node<T>(ofType type: T.Type,
                 from contact: SKPhysicsContact) -> T? {
        if let node = contact.bodyA.node as? T {
            return node
        }
        
        return contact.bodyB.node as? T
    }
    
    func fishFed(_ food: Food, _ guppy: Guppy) {
        guppy.updateGrowthPoint(numPoints: food.quality.growthPoints)
        guppy.animateEat()
        guppy.hunger += food.quality.refillValue
        guppy.targetFood = nil
        
        food.removeAllActions()
        food.removeFromParent()
        
        state.removeFood(food)
    }
    
    func despawnItem(_ item: SKSpriteNode, isFood: Bool) {
        let despawn: SKAction
        
        if item.action(forKey: "despawn") == nil {
            let waitAction = SKAction.wait(forDuration: despawnTime)
            
            if isFood {
                let runAction = SKAction.run { [weak self, weak item] in
                    guard let self, let item else { return }
                    self.state.removeFood(item)
                }
                
                despawn = SKAction.sequence([
                    waitAction,
                    runAction,
                    .removeFromParent()
                ])
            } else {
                despawn = SKAction.sequence([
                    waitAction,
                    .removeFromParent()
                ])
            }
            
            item.run(despawn, withKey: "despawn")
        }
    }
    
    func setupConfig(_ config: LevelConfig) {
        self.config = config
    }
    
    func setupUI() {
        walletLabel.position = CGPoint(x: size.width - 150, y: size.height - 135)
        walletLabel.fontSize = 45
        walletLabel.fontColor = .white
        walletLabel.zPosition = 1
        addChild(walletLabel)
        updateWalletLabel()
        
        let levelLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        levelLabel.position = CGPoint(x: size.width - 150, y: size.height - 50)
        levelLabel.text = "\(config.aquarium) - \(config.level)"
        levelLabel.fontSize = 30
        levelLabel.fontColor = .white
        levelLabel.zPosition = 1
        addChild(levelLabel)
        
        addBuyGuppyButton()
        addBuyEggButton()
        addUpgradeFoodButton()
        addIncreaseFoodButton()
        addBuyCarnivoreButton()
    }
    
    func setupMenu() {
        menu.anchorPoint = CGPoint(x: 0, y: 1)
        menu.size = CGSize(width: self.size.width + 8, height: size.height / 5)
        menu.position = CGPoint(x: -4, y: size.height + 10)
        menu.name = "menu"
        
        addChild(menu)
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupGround() {
        ground.position = .zero
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: groundY), to: CGPoint(x: self.size.width, y: groundY))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.food
        ground.physicsBody?.collisionBitMask = PhysicsCategory.food
        
        addChild(ground)
    }
    
    func spawnFood(at position: CGPoint) {
        let food = Food(quality: state.foodQuality)
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
        
        state.addFood(food)
        addChild(food)
    }
    
    func spawnGuppy() {
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
        
        guppy.position = randomSpawnPoint(for: guppy.size)
        guppy.physicsBody = SKPhysicsBody(circleOfRadius: guppy.size.width / 2)
        guppy.physicsBody?.affectedByGravity = false
        guppy.physicsBody?.isDynamic = true
        guppy.physicsBody?.categoryBitMask = PhysicsCategory.guppy
        guppy.physicsBody?.contactTestBitMask = PhysicsCategory.food
        guppy.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        state.addGuppy(guppy)
        addChild(guppy)
        guppy.startState()
    }
    
    func spawnCarnivore() {
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
       
        carnivore.position = randomSpawnPoint(for: carnivore.size)
        carnivore.physicsBody = SKPhysicsBody(circleOfRadius: carnivore.size.width / 2)
        carnivore.physicsBody?.affectedByGravity = false
        carnivore.physicsBody?.isDynamic = true
        carnivore.physicsBody?.categoryBitMask = PhysicsCategory.carnivore
        carnivore.physicsBody?.contactTestBitMask = PhysicsCategory.guppy
        carnivore.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        state.addCarnivore(carnivore)
        addChild(carnivore)
        carnivore.startState()
        return
    }
    
    func spawnAlien(alienType: AlienType) {
        let alien = Alien(alienType: alienType)
        
        alien.position = randomSpawnPoint(for: alien.size)
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.width / 2)
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = PhysicsCategory.alien
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.guppy | PhysicsCategory.carnivore
        alien.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        state.addAlien(alien)
        addChild(alien)
    }
    
    private func randomSpawnPoint(for fishSize: CGSize) -> CGPoint {
        let adjustedMaxY = maxY - (fishSize.width / 2)
        
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomY = CGFloat.random(in: minY...adjustedMaxY)
        
        return CGPoint(x: randomX, y: randomY)
    }

    func spawnMoney(at position: CGPoint, type: MoneyType) {
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

        addChild(money)
    }
    
    func findNearestFood(to fish: Fish) -> SKSpriteNode? {
        let detectionRangeFood: CGFloat = 500
        let detectionRangeFish: CGFloat = 1000
        
        if fish is Guppy {
            return state.foodList
                .filter {
                    fish.getDistance(from: fish.position, to: $0.position) <= detectionRangeFood
                }
                .min {
                    fish.getDistance(from: fish.position, to: $0.position) <
                    fish.getDistance(from: fish.position, to: $1.position)
                }
        }
        
        return state.guppyList
            .filter { $0.guppySize == .small}
            .filter {
                fish.getDistance(from: fish.position, to: $0.position) <=
                    detectionRangeFish
            }
            .min {
                fish.getDistance(from: fish.position, to: $0.position) <
                fish.getDistance(from: fish.position, to: $1.position)
            }
    }
    
    func findNearestFish(to alien: Alien) -> Fish? {
        let allFish = state.guppyList + state.carnivoreList
        
        return allFish
            .filter { !$0.isDead }
            .min {
                alien.getDistance(from: alien.position, to: $0.position) <
                alien.getDistance(from: alien.position, to: $1.position)
            }
    }
    
    func updateWalletLabel() {
        walletLabel.text = "$\(state.wallet)"
    }
    
    func addBuyGuppyButton() {
        buyGuppyButton.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        buyGuppyButton.position = CGPoint(x: 85, y: size.height - 85)
        buyGuppyButton.name = "buyGuppy"
        buyGuppyButton.zPosition = 1
        
        let guppyLabel = SKSpriteNode(texture: FishTextures.guppySmallSwim.first!)
        guppyLabel.size = CGSize(
            width: FishTextures.guppySmallSwim.first!.size().width * 3.5,
            height: FishTextures.guppySmallSwim.first!.size().height * 3.5,
        )
        guppyLabel.zPosition = 1
        guppyLabel.position = CGPoint(x: 0, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$100"
        label.zPosition = 1
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        buyGuppyButton.addChild(guppyLabel)
        buyGuppyButton.addChild(label)
        addChild(buyGuppyButton)
    }
    
    func addBuyCarnivoreButton() {
        buyCarnivoreButton.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        buyCarnivoreButton.position = CGPoint(x: size.width - 725, y: size.height - 85)
        buyCarnivoreButton.name = "buyCarnivore"
        buyCarnivoreButton.zPosition = 1
        
        let carnivoreLabel = SKSpriteNode(texture: FishTextures.carnivoreSwim.first!)
        carnivoreLabel.size = CGSize(
            width: FishTextures.carnivoreSwim.first!.size().width * 2.5,
            height: FishTextures.carnivoreSwim.first!.size().height * 2.5,
        )
        carnivoreLabel.position = CGPoint(x: 0, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$1000"
        label.zPosition = 1
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        buyCarnivoreButton.addChild(carnivoreLabel)
        buyCarnivoreButton.addChild(label)
        addChild(buyCarnivoreButton)
    }

    func addBuyEggButton() {
        buyEggButton.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        buyEggButton.position = CGPoint(x: size.width - 350, y: size.height - 85)
        buyEggButton.name = "buyEgg"
        buyEggButton.zPosition = 1
        
        eggLabel.size = CGSize(
            width: eggLabel.size.width * 2.5,
            height: eggLabel.size.height * 2.5
        )
        eggLabel.position = CGPoint(x: 0, y: 20)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$\(config.eggPrice)"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        buyEggButton.addChild(eggLabel)
        buyEggButton.addChild(label)
        addChild(buyEggButton)
    }
    
    func addUpgradeFoodButton() {
        upgradeFoodQuality.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        upgradeFoodQuality.position = CGPoint(x: 275, y: size.height - 85)
        upgradeFoodQuality.name = "upgradeQuality"
        upgradeFoodQuality.zPosition = 1
        
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.size = CGSize(
            width: arrow.size.width * 3.5,
            height: arrow.size.width * 3.5
        )
        arrow.position = CGPoint(x: 0, y: 15)
        
        foodUpgradeLabel1.size = CGSize (
            width: foodUpgradeLabel1.size.width * 3.0,
            height: foodUpgradeLabel2.size.height * 3.0
        )
        foodUpgradeLabel1.position = CGPoint(x: -40, y: 15)
        
        foodUpgradeLabel2.size = CGSize (
            width: foodUpgradeLabel2.size.width * 3.0,
            height: foodUpgradeLabel2.size.height * 3.0
        )
        foodUpgradeLabel2.position = CGPoint(x: 40, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$200"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)
        
        upgradeFoodQuality.addChild(arrow)
        upgradeFoodQuality.addChild(foodUpgradeLabel1)
        upgradeFoodQuality.addChild(foodUpgradeLabel2)
        upgradeFoodQuality.addChild(label)
        addChild(upgradeFoodQuality)
    }
    
    func addIncreaseFoodButton() {
        increaseFoodLimit.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        increaseFoodLimit.position = CGPoint(x: 460, y: size.height - 85)
        increaseFoodLimit.name = "increaseFoodLimit"
        increaseFoodLimit.zPosition = 1
        
        let foodLabel = SKSpriteNode(texture: ItemTextures.food1)
        foodLabel.size = CGSize(
            width: ItemTextures.food1.size().width * 3.0,
            height: ItemTextures.food1.size().height * 3.0
        )
        foodLabel.position = CGPoint(x: -20, y: 15)
        
        foodLimitLabel.fontSize = 30
        foodLimitLabel.name = "foodLimit"
        foodLimitLabel.verticalAlignmentMode = .center
        foodLimitLabel.horizontalAlignmentMode = .center
        foodLimitLabel.position = CGPoint(x: 20, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$300"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)
        
        increaseFoodLimit.addChild(foodLabel)
        increaseFoodLimit.addChild(foodLimitLabel)
        increaseFoodLimit.addChild(label)
        updateFoodLimitLabel()
        addChild(increaseFoodLimit)
    }
    
    func updateFoodLimitLabel() {
        for node in increaseFoodLimit.children {
            if let label = node as? SKLabelNode,
               label.name == "foodLimit"
            {
                label.text = "x\(state.foodLimit)"
            }
        }
    }
    
    func updateEggLabel() {
        eggLabel.texture = SKTexture(imageNamed: "egg_label_0\(state.eggCount)")
    }
    
    func updateUpgradeFoodLabel() {
        if state.foodQuality == maxQualityUpgrade {
            upgradeFoodQuality.removeAllChildren()
            
            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.fontColor = .white
            label.text = "Max"
            label.fontSize = 35
            label.position = CGPoint(x: 0, y: 0)
            upgradeFoodQuality.addChild(label)
        } else {
            foodUpgradeLabel1.texture = ItemTextures.food2
            foodUpgradeLabel2.texture = ItemTextures.food3
        }
    }
    
    func startLevel() {
        spawnGuppy()
        spawnGuppy()
        spawnAlien(alienType: AlienType.sylvester)
        
        hungerTimer?.invalidate()
        
        hungerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            for guppy in self.state.guppyList {
                guppy.update()
            }
            
            for carnivore in self.state.carnivoreList {
                carnivore.update()
            }
        }
                                         
    }
}
