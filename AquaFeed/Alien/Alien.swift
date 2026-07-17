//
//  Alien.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/17/26.
//

import SpriteKit

enum AlienType {
    case sylvester
    case balrog
    
    var health: Int {
        switch self {
        case.sylvester:
            return 100
        case.balrog:
            return 220
        }
    }
    
    var swimTextures: [SKTexture] {
        switch self {
        case.sylvester:
            return AlienTextures.sylvesterSwim
        case.balrog:
            return AlienTextures.balrogSwim
        }
    }
    
    var deadTexture: SKTexture {
        switch self {
        case.sylvester:
            return AlienTextures.sylvesterDead
        case.balrog:
            return AlienTextures.balrogDead
        }
    }
}

class Alien: SKSpriteNode {
    var health: Int
    var isDead: Bool = false
    var prey: Fish?
    var swimTextures: [SKTexture]
    var deadTexture: SKTexture
    var facingLeft: Bool = true

    init(alienType: AlienType) {
        self.health = alienType.health
        self.swimTextures = alienType.swimTextures
        self.deadTexture = alienType.deadTexture
        
        super.init(
            texture: alienType.swimTextures.first,
            color: .clear,
            size: CGSize(
                width: alienType.swimTextures.first!.size().width * 2.5,
                height: alienType.swimTextures.first!.size().height * 2.5
            )
        )
        
        startSwimming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startSwimming() {
        let swim = SKAction.repeatForever(
            .animate(
                with: swimTextures,
                timePerFrame: 0.08
            )
        )
        
        run(swim, withKey: "animation")
    }

    func die() {
        removeAllActions()
        
        texture = deadTexture
        physicsBody?.affectedByGravity = true
        
        let wait = SKAction.wait(forDuration: 0.5)
        run(wait) { [weak self] in
            if let self = self {
                self.isDead = true
                self.removeFromParent()
            }
        }
    }
    
    func getDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        return sqrt(dx * dx + dy * dy)
    }
    
    func frameUpdate() {
        if prey == nil {
            findPrey()
        }
        
        guard let prey = prey else { return }
        
        let dx = prey.position.x - position.x
        let dy = prey.position.y - position.y
        
        if dx > 0 && facingLeft {
            facingLeft = false
            turn()
        } else if dx < 0 && !facingLeft {
            facingLeft = true
            turn()
        }
        
        let distance = sqrt(dx * dx + dy * dy)
        if distance > 1 {
            let step = 100 / 60.0
            
            position.x += dx / distance * step
            position.y += dy / distance * step
        }
    }
    
    func findPrey() {
        if let levelScene = scene as? LevelScene,
           let target = levelScene.findNearestFish(to: self) {
            prey = target
        }
    }
    
    func turn() {
        removeAction(forKey: "animation")
        xScale *= -1
        startSwimming()
    }
    
    func decreaseHealth(damage: Int) {
        health -= damage
        health = max(0, health)
        
        if health == 0 {
            die()
        }
    }
    
    func bump(from touch: CGPoint) {
        let dx = position.x - touch.x
        let dy = position.y - touch.y
        
        let length = max(sqrt(dx * dx + dy * dy), 1)
        
        let bumpVelocity = CGVector(
            dx: dx / length * 20,
            dy: dy / length * 20
        )
        
        position.x += bumpVelocity.dx
        position.y += bumpVelocity.dy
    }
}
