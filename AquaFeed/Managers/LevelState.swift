import SwiftUI
import SpriteKit

class LevelState {
    static let shared = LevelState()
    
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
    var laserDamage: Int
    var laserUpgrade: Int
    var spawnEnemyTimer: Int
    var buttons: [MenuButton]
    
    private init() {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        carnivoreList = []
        alienList = []
        foodList = []
        moneyList = []
        petList = []
        buttons = []
        wallet = 200
        foodLimit = 1
        foodQuality = FoodQuality.level1
        eggCount = 0
        laserDamage = 10
        laserUpgrade = 1
        spawnEnemyTimer = 0
    }
    
    func setupLevel(config: LevelConfig) {
        pauseDuration = 1.0
        gameOver = false
        guppyList = []
        carnivoreList = []
        alienList = []
        foodList = []
        moneyList = []
        wallet = 100000
        foodLimit = 1
        foodQuality = FoodQuality.level1
        eggCount = 0
        laserDamage = 10
        spawnEnemyTimer = 0
    }
    
    func addMenuButton(button: MenuButton) {
        buttons.append(button)
    }
    
    func setEnemyTimer(time: Int) {
        spawnEnemyTimer = time
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
                stinky.updateTargetCoin()
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
                        stinky.updateTargetCoin()
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
        laserUpgrade += 1
        laserDamage += 20
    }
}
