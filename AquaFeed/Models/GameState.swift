//
//  GameState.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/6/26.
//

import SwiftUI
import SpriteKit

class GameState {
    var pauseDuration: Float
    var gameOver: Bool
    var guppyList: [Guppy]
    var piranhaList: [Piranha]
    var foodList: [SKSpriteNode]
    var wallet: Int
    var foodLimit: Int
    var foodQuality: FoodQuality
    var eggCount: Int
    
    init() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        piranhaList = []
        foodList = []
        wallet = 1000
        foodLimit = 1
        foodQuality = FoodQuality.level1
        eggCount = 0
    }
    
    func addGuppy(_ Guppy: Guppy) {
        guppyList.append(Guppy)
    }
    
    func removeDeadGuppy() {
        guppyList.removeAll { $0.isDead }
    }
    
    func addPiranha(_ Piranha: Piranha) {
        piranhaList.append(Piranha)
    }
    
    func removeDeadPiranha() {
        piranhaList.removeAll { $0.isDead }
    }
    
    func addFood(_ food: SKSpriteNode) {
        foodList.append(food)
    }
    
    func removeFood(_ food: SKSpriteNode) {
        foodList.removeAll { $0 == food }
    }
    
    func updateWallet(amount: Int) {
        wallet += amount
    }
    
    func increaseFoodLimit() {
        foodLimit += 1
    }
    
    func increaseEggCount() {
        eggCount += 1
    }
    
    func upgradeFood() {
        if foodQuality == FoodQuality.level1 {
            foodQuality = FoodQuality.level2
        } else if foodQuality == FoodQuality.level2 {
            foodQuality = FoodQuality.level3
        }
    }
}
