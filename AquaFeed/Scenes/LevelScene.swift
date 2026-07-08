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
    static let piranha: UInt32 = 0x1 << 4
}

let despawnTime = 1.5
let guppyPrice = 100
let pirahnaPrice = 1000
let upgradeFoodQualityCost = 200
let increaseFoodLimitCost = 300
let eggLimit = 3
let maxQualityUpgrade = FoodQuality.level3

class LevelScene: SKScene, SKPhysicsContactDelegate {
    var config: LevelConfig!
    var background = SKSpriteNode(imageNamed: "aquarium")
    var menu = SKSpriteNode(imageNamed: "menu")
    var walletLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var eggCountLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var foodLimitLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
    var buyFishButton = SKSpriteNode(color: .blue,
                                     size: CGSize(width: 170, height: 170))
    var buyEggButton = SKSpriteNode(color: .blue,
                                    size: CGSize(width: 170, height: 170))
    var upgradeFoodQuality = SKSpriteNode(color: .blue,
                                          size: CGSize(width: 170, height: 170))
    var increaseFoodLimit = SKSpriteNode(color: .blue,
                                         size: CGSize(width: 170, height: 170))
    var buyPiranhaButton = SKSpriteNode(color: .blue,
                                        size: CGSize(width: 170, height: 170))
    var ground = SKNode()
    
    var maxWidth: CGFloat {
        size.width
    }
    
    var maxHeight: CGFloat {
        size.height * 0.70
    }
    
    var groundY: CGFloat {
        (size.height - maxHeight) / 2 - 20
    }
    
    var centerX: CGFloat {
        size.width / 2
    }
    
    var centerY: CGFloat {
        size.height / 2
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
            
            if let buyFishButton = node as? SKSpriteNode,
               buyFishButton.name == "buyFish"
            {
                if buyFishButton.isHidden { return }
                
                if state.wallet >= guppyPrice {
                    state.updateWallet(amount: -guppyPrice)
                    spawnGuppy()
                    updateWalletLabel()
                }
                return
            }
            
            if let buyEggButton = node as? SKSpriteNode,
               buyEggButton.name == "buyEgg"
            {
                if buyEggButton.isHidden { return }
                
                if state.wallet >= config.eggPrice {
                    state.updateWallet(amount: -config.eggPrice)
                    updateWalletLabel()
                    state.increaseEggCount()
                    updateEggCountLabel()
                }
                return
            }
            
            if let upgradeFoodQuality = node as? SKSpriteNode,
               upgradeFoodQuality.name == "upgradeQuality"
            {
                if upgradeFoodQuality.isHidden { return }
                if state.foodQuality == maxQualityUpgrade { return }
                
                if state.wallet >= upgradeFoodQualityCost {
                    state.updateWallet(amount: -upgradeFoodQualityCost)
                    updateWalletLabel()
                    state.upgradeFood()
                }
            }
            
            if let increaseFoodLimit = node as? SKSpriteNode,
               increaseFoodLimit.name == "increaseFoodLimit"
            {
                if increaseFoodLimit.isHidden { return }
                
                if state.wallet >= increaseFoodLimitCost {
                    state.updateWallet(amount: -increaseFoodLimitCost)
                    updateWalletLabel()
                    state.increaseFoodLimit()
                    updateFoodLimitLabel()
                }
            }
            
            if let buyPiranhaButton = node as? SKSpriteNode,
               buyPiranhaButton.name == "buyPiranha"
            {
                if buyPiranhaButton.isHidden { return }
                
                if state.wallet >= pirahnaPrice {
                    state.updateWallet(amount: -pirahnaPrice)
                    updateWalletLabel()
                    spawnPiranha()
                }
            }
            
            if let menu = node as? SKSpriteNode,
               menu.name == "menu"
            { return }
        }
        
        guard location.y > groundY else { return }
        if state.foodList.count < state.foodLimit {
            if state.wallet >= 5 {
                state.updateWallet(amount: -5)
                spawnFood(at: location)
                updateWalletLabel()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        for guppy in state.guppyList {
            guppy.frameUpdate()
        }
        
        for piranha in state.piranhaList {
            piranha.frameUpdate()
        }
        
        state.removeDeadGuppy()
        state.removeDeadPiranha()
        
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
            var food: SKSpriteNode?

            let firstBody = contact.bodyA.categoryBitMask
            let secondBody = contact.bodyB.categoryBitMask
            
            if firstBody == PhysicsCategory.food {
                food = contact.bodyA.node as? SKSpriteNode
            } else if secondBody == PhysicsCategory.food {
                food = contact.bodyB.node as? SKSpriteNode
            }
            
            guard let food else { return }
            
            despawnItem(food, isFood: true)
        }
        
        if categories == PhysicsCategory.food | PhysicsCategory.guppy {
            var food: Food?
            var guppy: Guppy?
            
            let firstBody = contact.bodyA.categoryBitMask
            let secondBody = contact.bodyB.categoryBitMask
            
            if firstBody == PhysicsCategory.food {
                food = contact.bodyA.node as? Food
                guppy = contact.bodyB.node as? Guppy
            } else if secondBody == PhysicsCategory.food {
                food = contact.bodyB.node as? Food
                guppy = contact.bodyA.node as? Guppy
            }
            
            guard let food else { return }
            guard let guppy else { return }
            
            fishFed(food, guppy)
        }
        
        if categories == PhysicsCategory.money | PhysicsCategory.ground {
            var money: Money?
            
            let firstBody = contact.bodyA.categoryBitMask
            let secondBody = contact.bodyB.categoryBitMask
            
            if firstBody == PhysicsCategory.money {
                money = contact.bodyA.node as? Money
            } else if secondBody == PhysicsCategory.money {
                money = contact.bodyB.node as? Money
            }
            
            guard let money else { return }
            
            despawnItem(money, isFood: false)
        }
        
        if categories == PhysicsCategory.piranha | PhysicsCategory.guppy {
            var guppy: Guppy?
            var piranha: Piranha?
            
            let firstBody = contact.bodyA.categoryBitMask
            let secondBody = contact.bodyB.categoryBitMask
            
            if firstBody == PhysicsCategory.piranha {
                piranha = contact.bodyA.node as? Piranha
                guppy = contact.bodyB.node as? Guppy
            } else if secondBody == PhysicsCategory.piranha {
                piranha = contact.bodyB.node as? Piranha
                guppy = contact.bodyA.node as? Guppy
            }
            
            guard let piranha else { return }
            guard let guppy else { return }
            
            if piranha.state == FishState.seekFood {
                piranha.hunger += 60
                if piranha.hunger > 30 {
                    piranha.color = .black
                }
                piranha.targetFood = nil
                
                guppy.die()
                piranha.enterWanderState()
            }
        }
    }
    
    func fishFed(_ food: Food, _ guppy: Guppy) {
        guppy.hunger += food.quality.refillValue
        guppy.updateGrowthPoint(numPoints: food.quality.growthPoints)
        if guppy.hunger > 15 {
            guppy.color = .orange
        }
        guppy.targetFood = nil
        
        food.removeAllActions()
        food.removeFromParent()
        
        state.removeFood(food)
        
        guppy.enterWanderState()
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
        
        eggCountLabel.position = CGPoint(x: size.width - 150, y: 10)
        eggCountLabel.fontSize = 30
        eggCountLabel.fontColor = .white
        eggCountLabel.zPosition = 1
        addChild(eggCountLabel)
        updateEggCountLabel()
        
        let levelLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        levelLabel.position = CGPoint(x: size.width - 150, y: size.height - 50)
        levelLabel.text = "\(config.aquarium) - \(config.level)"
        levelLabel.fontSize = 30
        levelLabel.fontColor = .white
        levelLabel.zPosition = 1
        addChild(levelLabel)
        
        addBuyFishButton()
        addBuyEggButton()
        addUpgradeFoodButton()
        addIncreaseFoodButton()
        addBuyPiranhaButton()
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
    
    // TODO: REMOVE THIS ONCE FINISHED
    // Helper function to dictate boundary of where fish can swim
    func setupBoundary() {
        boundary.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(boundary)
    }
    
    // TODO: REMOVE THIS ONCE FINISHED
    func addHorizontalLine() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: groundY))
        path.addLine(to: CGPoint(x: self.size.width, y: groundY))
        
        let line = SKShapeNode(path: path)
        line.strokeColor = .white
        line.lineWidth = 2
        
        addChild(line)
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
        // TODO: REPLACE WITH VARIABLES HERE
        let guppy = Guppy(color: .orange, size: CGSize(width: 30, height: 30))
        let minY =  (size.height - maxHeight) / 2
        let maxY = size.height - (size.height * (0.20)) - (guppy.size.width / 2)
        
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomY = CGFloat.random(in: minY...maxY)
        
        guppy.position = CGPoint(x: randomX, y: minY)
        
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
    
    func spawnPiranha() {
        let piranha = Piranha(color: .black, size: CGSize(width: 50, height: 50))
        
        let minY =  (size.height - maxHeight) / 2
        let maxY = size.height - (size.height * (0.20)) - (piranha.size.width / 2)
        
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomY = CGFloat.random(in: minY...maxY)
        
        piranha.position = CGPoint(x: randomX, y: randomY)
        
        piranha.physicsBody = SKPhysicsBody(circleOfRadius: piranha.size.width / 2)
        piranha.physicsBody?.affectedByGravity = false
        piranha.physicsBody?.isDynamic = true
        piranha.physicsBody?.categoryBitMask = PhysicsCategory.piranha
        piranha.physicsBody?.contactTestBitMask = PhysicsCategory.guppy
        piranha.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        state.addPiranha(piranha)
        addChild(piranha)
        piranha.startState()
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
        let detectionRange: CGFloat = 500
        
        return state.foodList
            .filter {
                fish.getDistance(from: fish.position, to: $0.position) <= detectionRange
            }
            .min {
                fish.getDistance(from: fish.position, to: $0.position) <
                fish.getDistance(from: fish.position, to: $1.position)

            }
    }
    
    func findNearestBabyGuppy(to piranha: Piranha) -> Guppy? {
        let detectionRange: CGFloat = 500
        
        return state.guppyList
            .filter { $0.guppySize == .small}
            .filter {
                piranha.getDistance(from: piranha.position, to: $0.position) <=
                    detectionRange
            }
            .min {
                piranha.getDistance(from: piranha.position, to: $0.position) <
                piranha.getDistance(from: piranha.position, to: $1.position)

            }
    }
    
    func updateWalletLabel() {
        walletLabel.text = "$\(state.wallet)"
    }
    
    func addBuyFishButton() {
        buyFishButton.position = CGPoint(x: 80, y: size.height - 80)
        buyFishButton.name = "buyFish"
        buyFishButton.zPosition = 1
        let label1 = SKLabelNode(fontNamed: "Menlo-Bold")
        label1.text = "Buy Guppy"
        label1.zPosition = 1
        label1.fontSize = 25
        label1.fontColor = .white
        label1.verticalAlignmentMode = .center
        label1.horizontalAlignmentMode = .center
        label1.position = CGPoint(x: 0, y: 15)
        
        let label2 = SKLabelNode(fontNamed: "Menlo-Bold")
        label2.text = "$100"
        label2.zPosition = 1
        label2.fontSize = 25
        label2.fontColor = .white
        label2.verticalAlignmentMode = .center
        label2.horizontalAlignmentMode = .center
        label2.position = CGPoint(x: 0, y: -15)

        buyFishButton.addChild(label1)
        buyFishButton.addChild(label2)
        addChild(buyFishButton)
    }
    
    func addBuyPiranhaButton() {
        buyPiranhaButton.position = CGPoint(x: size.width - 725, y: size.height - 80)
        buyPiranhaButton.name = "buyPiranha"
        buyPiranhaButton.zPosition = 1
        let label1 = SKLabelNode(fontNamed: "Menlo-Bold")
        label1.text = "Buy Piranha"
        label1.zPosition = 1
        label1.fontSize = 25
        label1.fontColor = .white
        label1.verticalAlignmentMode = .center
        label1.horizontalAlignmentMode = .center
        label1.position = CGPoint(x: 0, y: 15)
        
        let label2 = SKLabelNode(fontNamed: "Menlo-Bold")
        label2.text = "$1000"
        label2.zPosition = 1
        label2.fontSize = 25
        label2.fontColor = .white
        label2.verticalAlignmentMode = .center
        label2.horizontalAlignmentMode = .center
        label2.position = CGPoint(x: 0, y: -15)

        buyPiranhaButton.addChild(label1)
        buyPiranhaButton.addChild(label2)
        addChild(buyPiranhaButton)
    }

    func addBuyEggButton() {
        buyEggButton.position = CGPoint(x: size.width - 350, y: size.height - 80)
        buyEggButton.name = "buyEgg"
        buyEggButton.zPosition = 1
        let label1 = SKLabelNode(fontNamed: "Menlo-Bold")
        label1.text = "Buy Egg"
        label1.fontSize = 25
        label1.fontColor = .white
        label1.verticalAlignmentMode = .center
        label1.horizontalAlignmentMode = .center
        label1.position = CGPoint(x: 0, y: 15)
        
        let label2 = SKLabelNode(fontNamed: "Menlo-Bold")
        label2.text = "$\(config.eggPrice)"
        label2.fontSize = 25
        label2.fontColor = .white
        label2.verticalAlignmentMode = .center
        label2.horizontalAlignmentMode = .center
        label2.position = CGPoint(x: 0, y: -15)

        buyEggButton.addChild(label1)
        buyEggButton.addChild(label2)
        addChild(buyEggButton)
    }
    
    func addUpgradeFoodButton() {
        upgradeFoodQuality.position = CGPoint(x: 275, y: size.height - 80)
        upgradeFoodQuality.name = "upgradeQuality"
        upgradeFoodQuality.zPosition = 1
        
        let label1 = SKLabelNode(fontNamed: "Menlo-Bold")
        label1.text = "Upgrade Food"
        label1.fontSize = 20
        label1.fontColor = .white
        label1.verticalAlignmentMode = .center
        label1.horizontalAlignmentMode = .center
        label1.position = CGPoint(x: 0, y: 15)
        
        let label2 = SKLabelNode(fontNamed: "Menlo-Bold")
        label2.text = "$200"
        label2.fontSize = 25
        label2.fontColor = .white
        label2.verticalAlignmentMode = .center
        label2.horizontalAlignmentMode = .center
        label2.position = CGPoint(x: 0, y: -15)
        
        upgradeFoodQuality.addChild(label1)
        upgradeFoodQuality.addChild(label2)
        addChild(upgradeFoodQuality)
    }
    
    func addIncreaseFoodButton() {
        increaseFoodLimit.position = CGPoint(x: 460, y: size.height - 80)
        increaseFoodLimit.name = "increaseFoodLimit"
        increaseFoodLimit.zPosition = 1
        
        foodLimitLabel.fontSize = 25
        foodLimitLabel.name = "foodLimit"
        foodLimitLabel.verticalAlignmentMode = .center
        foodLimitLabel.horizontalAlignmentMode = .center
        foodLimitLabel.position = CGPoint(x: 0, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$300"
        label.fontSize = 25
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -15)
        
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
    
    func updateEggCountLabel() {
        eggCountLabel.text = "Egg Pieces: \(state.eggCount)"
    }
    
    func startLevel() {
        spawnGuppy()
        spawnGuppy()
        
        hungerTimer?.invalidate()
        
        hungerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            for guppy in self.state.guppyList {
                guppy.update()
            }
            
            for piranha in self.state.piranhaList {
                piranha.update()
            }
        }
                                         
    }
}
