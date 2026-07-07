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
}

let despawnTime = 1.5
let guppyPrice = 100
let eggLimit = 3

class LevelScene: SKScene, SKPhysicsContactDelegate {
    var config: LevelConfig!
    
    var background = SKSpriteNode(imageNamed: "aquarium")
    var walletLabel = SKLabelNode(fontNamed: "Chalkduster")
    var eggCountLabel = SKLabelNode(fontNamed: "Chalkduster")
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
    var buyFishButton = SKSpriteNode(color: .green,
                                     size: CGSize(width: 200, height: 100))
    
    var buyEggButton = SKSpriteNode(color: .green,
                                    size: CGSize(width: 300, height: 100))
    
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
        setupBackground()
        setupGround()
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
        
        state.removeDeadGuppy()
        
        // Temporary Game Over Scene
        if state.eggCount == eggLimit {
            guard let view = self.view else { return }
            
            let endLevelScene = EndScene(size: size)
            let transition = SKTransition.fade(with: .black, duration: 1)
            view.presentScene(endLevelScene, transition: transition)
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
            var food: SKSpriteNode?
            var guppy: Guppy?
            
            let firstBody = contact.bodyA.categoryBitMask
            let secondBody = contact.bodyB.categoryBitMask
            
            if firstBody == PhysicsCategory.food {
                food = contact.bodyA.node as? SKSpriteNode
                guppy = contact.bodyB.node as? Guppy
            } else if secondBody == PhysicsCategory.food {
                food = contact.bodyB.node as? SKSpriteNode
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
    }
    
    func fishFed(_ food: SKSpriteNode, _ guppy: Guppy) {
        guppy.hunger += 8
        guppy.updateGrowthPoint(numPoints: 1)
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
        walletLabel.position = CGPoint(x: size.width - 150, y: size.height - 80)
        walletLabel.fontSize = 30
        walletLabel.fontColor = .white
        addChild(walletLabel)
        updateWalletLabel()
        
        eggCountLabel.position = CGPoint(x: size.width - 150, y: size.height - 120)
        eggCountLabel.fontSize = 30
        eggCountLabel.fontColor = .white
        addChild(eggCountLabel)
        updateEggCountLabel()

        addBuyFishButton()
        addBuyEggButton()
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
        let food = SKSpriteNode(color: .yellow, size: CGSize(width: 10, height: 10))
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
        let maxY = ((size.height - maxHeight) / 2) + maxHeight

        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomY = CGFloat.random(in: minY...maxY)

        guppy.position = CGPoint(x: randomX, y: randomY)
        
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
    
    func updateWalletLabel() {
        walletLabel.text = "Money: $\(state.wallet)"
    }
    
    func addBuyFishButton() {
        buyFishButton.position = CGPoint(x: 100, y: size.height - 100)
        buyFishButton.name = "buyFish"
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Buy Fish: $100"
        
        label.fontSize = 15
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        buyFishButton.addChild(label)
        addChild(buyFishButton)
    }
    
    func addBuyEggButton() {
        buyEggButton.position = CGPoint(x: size.width - 450, y: size.height - 100)
        buyEggButton.name = "buyEgg"
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Buy Egg: $\(config.eggPrice)"
        
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        buyEggButton.addChild(label)
        addChild(buyEggButton)
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
        }
                                         
    }
}
