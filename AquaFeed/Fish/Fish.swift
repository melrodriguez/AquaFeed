//
//  Fish.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/4/26.
//

import SpriteKit
import SwiftUI

let swimAnimationSpeedMultiplier: CGFloat = 0.0004
let swimFoodSpeedMultiplier: CGFloat = 1.05

class Fish: SKSpriteNode {
    var state: FishState = .wander
    var swimSpeed: CGFloat
    var swimTextures: [SKTexture]
    var turnTextures: [SKTexture]
    var eatTexutures: [SKTexture]
    var facingLeft: Bool = true
    var hunger: Int
    var isStarvingTime: Int
    var spawnCoinTime: Int
    var timeTillSpawnCoin: Int
    var isDead: Bool = false
    var moneyDrop: MoneyType?
    var targetFood: SKSpriteNode?
    var type: String

    var sceneWidth: CGFloat {
        self.scene?.size.width ?? 0
    }
    
    var sceneHeight: CGFloat {
        self.scene?.size.height ?? 0
    }
    
    var maxX: CGFloat {
        sceneWidth
    }
    
    var maxY: CGFloat {
        sceneHeight * 0.70
    }
    
    var centerX: CGFloat {
        sceneWidth / 2
    }
    
    var centerY: CGFloat {
        sceneHeight / 2
    }
    
    init(
        swimTextures: [SKTexture],
        turnTextures: [SKTexture],
        eatTextures: [SKTexture],
        scale: CGFloat,
        swimSpeed: CGFloat,
        hunger: Int,
        isStarvingTime: Int,
        spawnCoinTime: Int,
        moneyDrop: MoneyType? = nil,
        type: String
    ) {
        self.swimTextures = swimTextures
        self.turnTextures = turnTextures
        self.eatTexutures = eatTextures
        self.swimSpeed = swimSpeed
        self.hunger = hunger
        self.isStarvingTime = isStarvingTime
        self.spawnCoinTime = spawnCoinTime
        self.timeTillSpawnCoin = spawnCoinTime
        self.type = type
        
        if moneyDrop != nil {
            self.moneyDrop = moneyDrop
        }
        
        super.init(
            texture: swimTextures.first,
            color: .clear,
            size: CGSize(
                width: swimTextures.first!.size().width * scale,
                height: swimTextures.first!.size().height * scale
            )
        )
        
        setScale(scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startSwimming() {
        let swim = SKAction.repeatForever(
            .animate(
                with: swimTextures,
                timePerFrame: swimSpeed * swimAnimationSpeedMultiplier
            )
        )
        
        run(swim, withKey: "animation")
    }
    
    func turnFish(toRight: Bool) {
        removeAction(forKey: "animation")
        
        xScale = toRight ? abs(xScale) : -abs(xScale)
        
        let turn = SKAction.animate(
            with: turnTextures,
            timePerFrame: 0.06
        )
        
        run(turn) { [weak self] in
            guard let self = self else { return }
            self.xScale *= -1
            self.startSwimming()
        }
    }
    
    func startState() {
        startSwimming()
        enterWanderState()
    }
    
    func enterPauseState() {
        state = .pause
        
        let up = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        let down = SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        
        up.timingMode = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        
        let bob = SKAction.sequence([up, down])
        let loopBob = SKAction.repeatForever(bob)
        
        run(loopBob, withKey: "bob")
        
        let wait = SKAction.wait(forDuration: Double.random(in: 0.5 ... 2.0))
        
        run(wait) { [weak self] in
            guard let self = self else {return}
            self.removeAction(forKey: "bob")
            self.enterWanderState()
        }
    }
    
    func enterWanderState() {
        state = .wander
        
        var target = getWanderLocation()
        
        while getDistance(from: position, to: target) < 100 {
            target = getWanderLocation()
        }
        
        let distance = getDistance(from: position, to: target)
        let duration = TimeInterval(distance / swimSpeed)
        let moveAction = SKAction.move(to: target,
                                       duration: duration)
        
        if target.x > position.x && facingLeft {
            
            facingLeft = false
            turnFish(toRight: true)
        } else if target.x < position.x && !facingLeft {
            facingLeft = true
            turnFish(toRight: false)
        }
        
        
        run(moveAction) { [weak self] in
            self?.enterPauseState()
        }
    }
    
    func getWanderLocation() -> CGPoint {
        let edgeInset: CGFloat = 50
        let maxVerticalChange: CGFloat = 80
        
        let rect = CGRect(
            x: edgeInset,
            y: (sceneHeight - maxY) - 150,
            width: sceneWidth - edgeInset * 2,
            height: maxY - 70
        )

        // Keeping this to test bounds further
//        guard let levelScene = scene as? LevelScene else { return .zero }
//        let debugRect = SKShapeNode(rect: rect)
//        debugRect.fillColor = .red
//        
//        levelScene.addChild(debugRect)
        
        switch Int.random(in: 0..<4) {
        case 0:
            return CGPoint(
                x: rect.minX,
                y: max(rect.minY,
                       min(rect.maxY,
                           position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                        )
            )
        case 1:
            return CGPoint(
                x: rect.maxX,
                y: max(rect.minY,
                       min(rect.maxY,
                           position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                        )
            )
        case 2:
            return CGPoint(
                x: CGFloat.random(in: rect.minX...rect.maxX),
                y: max(rect.minY,
                       min(rect.maxY,
                           position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                        )
            )
        default:
            return CGPoint(x: CGFloat.random(in: rect.minX...rect.maxX),
                           y: max(rect.minY,
                                  min(rect.maxY,
                                      position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                                   )
            )
        }
    }

    func getDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        return sqrt(dx * dx + dy * dy)
    }
    
    func update() {
        hunger -= 1
        hunger = max(hunger , 0)
        
        //TODO: Handle this shit buddy
        //color = hunger < isStarvingTime ? .red : .orange
        
        if hunger == 0 {
            die()
        }
        
        handleDropCoin()
    }
    
    func frameUpdate() {
        if hunger < 15,
           targetFood == nil {
            findFood()
        }
        
        if state == .seekFood, let food = targetFood {
            if food.parent == nil {
                targetFood = nil
                removeAllActions()
                enterWanderState()
                return
            }
            
            removeAllActions()
            
            let dx = food.position.x - position.x
            let dy = food.position.y - position.y
            
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance > 1 {
                let step = (swimSpeed * swimFoodSpeedMultiplier) / 60.0
                
                position.x += dx / distance * step
                position.y += dy / distance * step
            }
        }
    }
    
    func findFood() {
        if let levelScene = scene as? LevelScene,
           let food = levelScene.findNearestFood(to: self) {
            targetFood = food
            state = .seekFood
        }
    }

    func handleDropCoin() {
        timeTillSpawnCoin -= 1
        if timeTillSpawnCoin < 1 {
            guard let levelScene = scene as? LevelScene else { return }
            if moneyDrop != nil {
                levelScene.spawnMoney(at: self.position, type: moneyDrop!)
            }
            
            timeTillSpawnCoin = spawnCoinTime
        }
    }

    func die() {
        isDead = true
        removeFromParent()
    }
}
