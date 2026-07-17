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
    
    var color: SKColor {
        switch self {
        case.sylvester:
            return .blue
        case.balrog:
            return .orange
        }
    }
    
    var size: CGSize {
        switch self {
        case.sylvester:
            return CGSize(
                width: 100,
                height: 200
            )
        case.balrog:
            return CGSize(
                width: 100,
                height: 200
            )
        }
    }
}

class Alien: SKSpriteNode {
    var health: Int
    var isDead: Bool = false
    var prey: Fish?
    //var swimTextures: [SKTexture]
    
    init(alienType: AlienType) {
        self.health = alienType.health
        
        super.init(
            texture: nil,
            color: alienType.color,
            size: alienType.size
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func die() {
        removeFromParent()
        isDead = true
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
}
