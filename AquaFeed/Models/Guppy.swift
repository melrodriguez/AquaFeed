//
//  Guppy.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/4/26.
//

import SwiftUI
import SpriteKit

enum GuppySize {
    case small
    case medium
    case large
    
    var swimSpeed: CGFloat {
        switch self {
        case.small:
            return 200
        case.medium:
            return 180
        case.large:
            return 170
        }
    }
}

class Guppy: Fish {
    
    var guppySize: GuppySize = .small {
        didSet {
            swimSpeed = guppySize.swimSpeed
        }
    }
    
    var hunger: Int = 20
    var timeTillSpawnCoin: Int = 8
    var targetFood: Food?
    var growthPoints: Int = 2
    var isDead = false

    func update() {
        hunger -= 1
        hunger = max(hunger , 0)
        
        color = hunger < 15 ? .red : .orange
        
        if hunger == 0 {
            die()
        }
        
        if guppySize == .medium || guppySize == .large {
            timeTillSpawnCoin -= 1
            
            if timeTillSpawnCoin < 1 {
                guard let levelScene = scene as? LevelScene else { return }
                
                if guppySize == .medium {
                    levelScene.spawnMoney(at: self.position, type: .silver)
                } else {
                    levelScene.spawnMoney(at: self.position, type: .gold)
                }
                
                timeTillSpawnCoin = 8
            }
            
        }
    }
    
    func frameUpdate() {
        if hunger < 15,
           targetFood == nil,
           let levelScene = scene as? LevelScene,
           let food = levelScene.findNearestFood(to: self) {
            targetFood = food
            state = .seekFood
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
                let step = swimSpeed / 60.0
                
                position.x += dx / distance * step
                position.y += dy / distance * step
            }
        }
    }
    
    func updateGrowthPoint(numPoints: Int) {
        growthPoints += numPoints
        
        if guppySize == .small {
            if growthPoints > 6 { grow() }
        } else if guppySize == .medium {
            if growthPoints > 12 { grow() }
        }
    }
    
    func grow() {
        switch guppySize {
        case .small:
            guppySize = .medium
            size = CGSize(width: 40, height: 40)
        case .medium:
            guppySize = .large
            size = CGSize(width: 60, height: 60)
        case .large:
            break
        }
    }
    
    func die() {
        isDead = true
        removeFromParent()
    }
    
}
