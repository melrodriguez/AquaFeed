//
//  Carnivore.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/10/26.
//

import SwiftUI
import SpriteKit

//class Carnivore: Fish {
//    var hunger: Int = 60
//    var timeTillSpawnCoin: Int = 15
//    var targetFood: Guppy?
//    var isDead = false
//
//    func update() {
//        hunger -= 1
//        hunger = max(hunger , 0)
//        
//        color = hunger < 20 ? .yellow : .black
//        
//        if hunger == 0 {
//            die()
//        }
//        
//        timeTillSpawnCoin -= 1
//        
//        if timeTillSpawnCoin < 1 {
//            guard let levelScene = scene as? LevelScene else { return }
//            
//            levelScene.spawnMoney(at: self.position, type: .diamond)
//            
//            timeTillSpawnCoin = 15
//        }
//    }
//    
//    func frameUpdate() {
//        if hunger < 30,
//           targetFood == nil,
//           let levelScene = scene as? LevelScene,
//           let food = levelScene.findNearestBabyGuppy(to: self) {
//            targetFood = food
//            state = .seekFood
//        }
//        
//        if state == .seekFood, let food = targetFood {
//            if food.parent == nil {
//                targetFood = nil
//                removeAllActions()
//                enterWanderState()
//                return
//            }
//            
//            removeAllActions()
//            
//            let dx = food.position.x - position.x
//            let dy = food.position.y - position.y
//            
//            let distance = sqrt(dx * dx + dy * dy)
//            
//            if distance > 1 {
//                let step = swimSpeed / 60.0
//                
//                position.x += dx / distance * step
//                position.y += dy / distance * step
//            }
//        }
//    }
//    
//    func die() {
//        isDead = true
//        removeFromParent()
//    }
//    
//}
