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
    var carnivoreList: [Carnivore]
    var alienList: [Alien]
    var foodList: [Food]
    var wallet: Int
    var foodLimit: Int
    var foodQuality: FoodQuality
    var eggCount: Int
    var gunDamage: Int
    
    init() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        carnivoreList = []
        alienList = []
        foodList = []
        wallet = 200
        foodLimit = 1
        foodQuality = FoodQuality.level1
        eggCount = 0
        gunDamage = 10
    }
    
    func addGuppy(_ Guppy: Guppy) {
        guppyList.append(Guppy)
    }
    
    func removeDeadGuppy() {
        guppyList.removeAll { $0.isDead }
    }
    
    func addCarnivore(_ Carnivore: Carnivore) {
        carnivoreList.append(Carnivore)
    }
    
    func removeDeadCarnivore() {
        carnivoreList.removeAll { $0.isDead }
    }
    
    func addAlien(_ Alien: Alien) {
        alienList.append(Alien)
    }
    
    func removeDeadAlien() {
        alienList.removeAll { $0.isDead }
    }

    func addFood(_ food: Food) {
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
