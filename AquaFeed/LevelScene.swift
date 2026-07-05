//
//  LevelScene.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/1/26.
//

import SpriteKit
import SwiftUI

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let food: UInt32 = 0x1 << 0
    static let guppy: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
}

class LevelScene: SKScene, SKPhysicsContactDelegate {
    var background = SKSpriteNode(imageNamed: "aquarium")
    var levelLabel = SKLabelNode(fontNamed: "Chalkduster")
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
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
    
    var gameOver = false
    var hungerTimer: Timer?
    var guppyList: [Guppy] = []

    override func didMove(to view: SKView) {
        setupBackground()
        //setupBoundary()
        //addHorizontalLine()
        setupGround()
        setupLevelLabel()
        startLevel()
        
        // enable collision detection
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        guard location.y > groundY else { return }
        spawnFood(at: location)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.categoryBitMask
        let secondBody = contact.bodyB.categoryBitMask
        
        var food: SKSpriteNode?
        
        if firstBody == PhysicsCategory.food {
            food = contact.bodyA.node as? SKSpriteNode
        } else if secondBody == PhysicsCategory.food {
            food = contact.bodyB.node as? SKSpriteNode
        }
        
        guard let food else { return }
        
        if food.action(forKey: "decay") == nil {
            let decay = SKAction.sequence([
                SKAction.wait(forDuration: 10.0),
                SKAction.removeFromParent()
            ])
            
            food.run(decay, withKey: "decay")
        }
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
        guppyList.append(guppy)
        addChild(guppy)
        guppy.startState()
        
    }
    
    func setupLevelLabel() {
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        levelLabel.fontSize = 100
        levelLabel.fontColor = .white
        levelLabel.text = "Level 1"
        addChild(levelLabel)
    }
    
    func startLevel() {
        spawnGuppy()
        spawnGuppy()
        
        hungerTimer?.invalidate()
        
        hungerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            for guppy in self.guppyList {
                guppy.update()
            }
        }
                                         
    }
}
