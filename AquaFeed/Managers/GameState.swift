import SwiftUI
import SpriteKit

class GameState {
    static let shared = GameState()
    
    var pauseDuration: Float
    var gameOver: Bool
    var guppyList: [Guppy]
    var carnivoreList: [Carnivore]
    var alienList: [Alien]
    var foodList: [Food]
    var moneyList: [Money]
    var petList: [Pet]
    var wallet: Int
    var foodLimit: Int
    var foodQuality: FoodQuality
    var eggCount: Int
    var gunDamage: Int
    var gunUpgrade: Int
    
    private init() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        carnivoreList = []
        alienList = []
        foodList = []
        moneyList = []
        petList = []
        wallet = 200
        foodLimit = 1
        foodQuality = FoodQuality.level1
        eggCount = 0
        gunDamage = 10
        gunUpgrade = 1
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
        
        for pet in petList {
            pet.alienAppeared()
        }
    }
    
    func removeDeadAlien() {
        alienList.removeAll { $0.isDead }
        
        if alienList.isEmpty {
            for pet in petList {
                pet.allAliensDisappeared()
            }
        }
    }

    func addFood(_ food: Food) {
        foodList.append(food)
    }
    
    func removeFood(_ food: SKSpriteNode) {
        foodList.removeAll { $0 == food }
    }
    
    func addMoney(_ money: Money) {
        moneyList.append(money)
        
        for pet in petList {
            if let stinky = pet as? Stinky {
                stinky.setState(.collectingCoin)
            }
        }
    }
    
    func removeMoney(_ money: SKSpriteNode) {
        moneyList.removeAll { $0 == money }
        
        for pet in petList {
            if let stinky = pet as? Stinky {
                if let targetMoney = stinky.targetMoney {
                    if money == targetMoney {
                        stinky.targetMoney = nil
                        stinky.setState(.wander)
                    }
                }
            }
        }
    }
    
    func addPet(_ pet: Pet) {
        petList.append(pet)
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
    
    func upgradeLaser() {
        gunUpgrade += 1
        gunDamage += 20
    }
}
