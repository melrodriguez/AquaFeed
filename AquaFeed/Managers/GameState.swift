import SwiftUI
import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let food: UInt32 = 0x1 << 0
    static let guppy: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let money: UInt32 = 0x1 << 3
    static let carnivore: UInt32 = 0x1 << 4
    static let alien: UInt32 = 0x1 << 5
}

class GameState {
    static let shared = GameState()
    
    var pauseDuration: Float
    var gameOver: Bool
    var guppyList: [Guppy]
    var carnivoreList: [Carnivore]
    var alienList: [Alien]
    var foodList: [Food]
    var moneyList: [Money]
    var wallet: Int
    var foodLimit: Int
    var foodQuality: FoodQuality
    var eggCount: Int
    var gunDamage: Int
    
    private init() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        carnivoreList = []
        alienList = []
        foodList = []
        moneyList = []
        wallet = 200
        foodLimit = 1
        foodQuality = FoodQuality.level1
        eggCount = 0
        gunDamage = 10
    }
    
    func restartLevel() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        carnivoreList = []
        alienList = []
        foodList = []
        moneyList = []
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
    
    func addMoney(_ money: Money) {
        moneyList.append(money)
    }
    
    func removeMoney(_ money: SKSpriteNode) {
        moneyList.removeAll { $0 == money }
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
