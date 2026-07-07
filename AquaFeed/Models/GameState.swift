//
//  GameState.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/6/26.
//

import SwiftUI
import SpriteKit

let eggLimit = 3

class GameState {
    var pauseDuration: Float
    var gameOver: Bool
    var guppyList: [Guppy]
    var foodList: [SKSpriteNode]
    var wallet: Int
    var foodLimit: Int
    var eggCount: Int
    
    init() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        foodList = []
        wallet = 200
        foodLimit = 1
        eggCount = 0
    }
    
    func addGuppy(_ Guppy: Guppy) {
        guppyList.append(Guppy)
    }
    
    func removeDeadGuppy() {
        guppyList.removeAll { $0.isDead }
    }
    
    func addFood(_ food: SKSpriteNode) {
        foodList.append(food)
    }
    
    func removeFood(_ food: SKSpriteNode) {
        print("remove food")
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
}
