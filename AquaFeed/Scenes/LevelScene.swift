//
//  LevelScene.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/1/26.
//

import SpriteKit
import SwiftUI

let despawnTime = 1.5
let guppyPrice = 100
let carnivorePrice = 1000
let upgradeFoodQualityCost = 200
let increaseFoodLimitCost = 300
let eggLimit = 3
let maxQualityUpgrade = FoodQuality.level3

class LevelScene: SKScene, SKPhysicsContactDelegate {
    var config: LevelConfig!
    var background = SKSpriteNode(imageNamed: "aquarium")
    var menu = SKSpriteNode(imageNamed: "menu")
    var walletLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var eggLabel = SKSpriteNode(imageNamed: "egg_label_00")
    var foodLimitLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
    var buyGuppyButton = SKSpriteNode(imageNamed: "menu_board")
    var buyEggButton = SKSpriteNode(imageNamed: "menu_board")
    var upgradeFoodQuality = SKSpriteNode(imageNamed: "menu_board")
    var increaseFoodLimit = SKSpriteNode(imageNamed: "menu_board")
    var buyCarnivoreButton = SKSpriteNode(imageNamed: "menu_board")
    var foodUpgradeLabel1 = SKSpriteNode(texture: ItemTextures.food1)
    var foodUpgradeLabel2 = SKSpriteNode(texture: ItemTextures.food2)
    var ground = SKNode()
    lazy var spawnManager = SpawnManager(scene: self)
    
    var maxHeight: CGFloat {
        size.height * 0.70
    }
    
    var minY: CGFloat {
        (size.height - maxHeight) / 2
    }
    
    var maxY: CGFloat {
        size.height - (size.height * (0.20))
    }
    
    var groundY: CGFloat {
        (size.height - maxHeight) / 2 - 20
    }
    
    var pauseDuration = 1.0;
    let state = GameState.shared
    
    var hungerTimer: Timer?

    override func didMove(to view: SKView) {
        // This is just for testing purposes
        state.restartLevel()
        
        if config.level == 100 {
            state.wallet = 4000
        }
        

        setupBackground()
        setupGround()
        setupMenu()
        setupUI()
        startLevel()
        
        // enable collision detection
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if let money = node as? Money {
                state.updateWallet(amount: money.type.value)
                updateWalletLabel()
                money.setMoneyAsCollected()
                money.removeFromParent()
                state.removeMoney(money)
                return
            }
            
            if let alien = node as? Alien {
                if alien.isDead { return }
                alien.decreaseHealth(damage: state.gunDamage)
                alien.bump(from: location)
            }
            
            handleNodeButtons(node)
            
            // Prevent dropping food when clicking menu
            if let menu = node as? SKSpriteNode,
               menu.name == "menu"
            { return }
        }
        
        // Drop Food
        guard location.y > groundY else { return }
        if state.foodList.count < state.foodLimit {
            if state.wallet >= 5 {
                state.updateWallet(amount: -5)
                spawnManager.spawnFood(at: location, quality: state.foodQuality)
                updateWalletLabel()
            }
        }
    }
    
    private func handleNodeButtons(_ node: SKNode) {
        switch node.name {
        case "buyGuppy":
            buyGuppy()
            
        case "buyEgg":
            buyEgg()
        
        case "upgradeQuality":
            buyFoodQualityUpgrade()
            
        case "increaseFoodLimit":
            buyFoodLimitIncrease()
        
        case "buyCarnivore":
            buyCarnivore()
        
        default:
            break
        }
    }
    
    func buyGuppy() {
        if buyGuppyButton.isHidden { return }
        
        if state.wallet >= guppyPrice {
            state.updateWallet(amount: -guppyPrice)
            spawnManager.spawnGuppy()
            updateWalletLabel()
        }
        return
    }
    
    func buyEgg() {
        if buyEggButton.isHidden { return }
        
        if state.wallet >= config.eggPrice {
            state.updateWallet(amount: -config.eggPrice)
            updateWalletLabel()
            state.increaseEggCount()
            updateEggLabel()
        }
        return
    }
    
    func buyFoodQualityUpgrade() {
        if upgradeFoodQuality.isHidden { return }
        
        if state.foodQuality == maxQualityUpgrade { return }
        
        if state.wallet >= upgradeFoodQualityCost {
            state.updateWallet(amount: -upgradeFoodQualityCost)
            updateWalletLabel()
            state.upgradeFood()
            updateUpgradeFoodLabel()
        }
    }
    
    func buyFoodLimitIncrease() {
        if increaseFoodLimit.isHidden { return }
        
        if state.wallet >= increaseFoodLimitCost {
            state.updateWallet(amount: -increaseFoodLimitCost)
            updateWalletLabel()
            state.increaseFoodLimit()
            updateFoodLimitLabel()
        }
    }
    
    func buyCarnivore() {
        if buyCarnivoreButton.isHidden { return }
        
        if state.wallet >= carnivorePrice {
            state.updateWallet(amount: -carnivorePrice)
            updateWalletLabel()
            spawnManager.spawnCarnivore()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        for guppy in state.guppyList {
            guppy.frameUpdate()
        }
        
        for carnivore in state.carnivoreList {
            carnivore.frameUpdate()
        }
        
        for alien in state.alienList {
            alien.frameUpdate()
        }
        
        for pet in state.petList {
            if let itchy = pet as? Itchy {
                if itchy.state == .charge && itchy.chaseAlien {
                    itchy.frameUpdate()
                }
            }
        }

        state.removeDeadGuppy()
        state.removeDeadCarnivore()
        state.removeDeadAlien()
        
        // Temporary Game Over Scene
        if state.eggCount == eggLimit {
            guard let view = self.view else { return }
            
            let titleScene = TitleScene(size: size)
            let transition = SKTransition.fade(with: .black, duration: 1)
            view.presentScene(titleScene, transition: transition)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if categories == PhysicsCategory.food | PhysicsCategory.ground {
            guard let food: Food = node(ofType: Food.self, from: contact) else { return }
            
            despawnItem(food, isFood: true)
        } else if categories == PhysicsCategory.food | PhysicsCategory.guppy {
            guard
                let food: Food = node(ofType: Food.self, from: contact),
                let guppy: Guppy = node(ofType: Guppy.self, from: contact)
            else { return }
                
            fishFed(food, guppy)
        } else if categories == PhysicsCategory.money | PhysicsCategory.ground {
            guard let money: Money = node(ofType: Money.self, from: contact) else { return }
            
            despawnItem(money, isFood: false)
        }
        else if categories == PhysicsCategory.carnivore | PhysicsCategory.guppy {
            guard
                let guppy: Guppy = node(ofType: Guppy.self, from: contact),
                let carnivore: Carnivore = node(ofType: Carnivore.self, from: contact)
            else { return }
            
            if carnivore.state == FishState.seekFood {
                carnivore.animateEat()
                carnivore.hunger += 60
                carnivore.targetFood = nil
                guppy.die(showDieAnimation: false)
            }
        }
        else if categories == PhysicsCategory.alien | PhysicsCategory.guppy ||
                    categories == PhysicsCategory.alien | PhysicsCategory.carnivore {
            guard
                let fish: Fish = node(ofType: Fish.self, from: contact),
                let alien: Alien = node(ofType: Alien.self, from: contact)
            else { return }
            
            fish.die(showDieAnimation: false)
            alien.prey = nil
        }
        else if categories == PhysicsCategory.stinky | PhysicsCategory.money {
            guard
                let money: Money = node(ofType: Money.self, from: contact)
            else { return }
            
            state.updateWallet(amount: money.type.value)
            updateWalletLabel()
            money.setMoneyAsCollected()
            money.removeFromParent()
            state.removeMoney(money)
            return
        }
        else if categories == PhysicsCategory.itchy | PhysicsCategory.alien {
            guard
                let itchy: Itchy = node(ofType: Itchy.self, from: contact),
                let alien: Alien = node(ofType: Alien.self, from:contact)
            else { return }
            
            itchy.isTouchingAlien = true
        }
    }
    
    func node<T>(ofType type: T.Type,
                 from contact: SKPhysicsContact) -> T? {
        if let node = contact.bodyA.node as? T {
            return node
        }
        
        return contact.bodyB.node as? T
    }
    
    func fishFed(_ food: Food, _ guppy: Guppy) {
        guppy.updateGrowthPoint(numPoints: food.quality.growthPoints)
        guppy.animateEat()
        guppy.hunger += food.quality.refillValue
        guppy.targetFood = nil
        
        food.removeAllActions()
        food.removeFromParent()
        
        state.removeFood(food)
    }
    
    func despawnItem(_ item: SKSpriteNode, isFood: Bool) {
        let despawn: SKAction
        
        if item.action(forKey: "despawn") == nil {
            let waitAction = SKAction.wait(forDuration: despawnTime)
            
            if isFood {
                let runAction = SKAction.run { [weak self, weak item] in
                    guard let self, let item else { return }
                    self.state.removeFood(item)
                }
                
                despawn = SKAction.sequence([
                    waitAction,
                    runAction,
                    .removeFromParent()
                ])
            } else {
                despawn = SKAction.sequence([
                    waitAction,
                    .removeFromParent()
                ])
            }
            
            item.run(despawn, withKey: "despawn")
        }
    }
    
    func setupConfig(_ config: LevelConfig) {
        self.config = config
    }
    
    func setupUI() {
        walletLabel.position = CGPoint(x: size.width - 150, y: size.height - 135)
        walletLabel.fontSize = 45
        walletLabel.fontColor = .white
        walletLabel.zPosition = 1
        addChild(walletLabel)
        updateWalletLabel()
        
        let levelLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        levelLabel.position = CGPoint(x: size.width - 150, y: size.height - 50)
        levelLabel.text = "\(config.aquarium) - \(config.level)"
        levelLabel.fontSize = 30
        levelLabel.fontColor = .white
        levelLabel.zPosition = 1
        addChild(levelLabel)
        
        addBuyGuppyButton()
        addBuyEggButton()
        addUpgradeFoodButton()
        addIncreaseFoodButton()
        addBuyCarnivoreButton()
    }
    
    func setupMenu() {
        menu.anchorPoint = CGPoint(x: 0, y: 1)
        menu.size = CGSize(width: self.size.width + 8, height: size.height / 5)
        menu.position = CGPoint(x: -4, y: size.height + 10)
        menu.name = "menu"
        
        addChild(menu)
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupGround() {
        ground.position = .zero
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: groundY), to: CGPoint(x: self.size.width, y: groundY))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.food
        ground.physicsBody?.collisionBitMask = PhysicsCategory.food
        
        addChild(ground)
    }
    
    
    func updateWalletLabel() {
        walletLabel.text = "$\(state.wallet)"
    }
    
    func addBuyGuppyButton() {
        buyGuppyButton.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        buyGuppyButton.position = CGPoint(x: 85, y: size.height - 85)
        buyGuppyButton.name = "buyGuppy"
        buyGuppyButton.zPosition = 1
        
        let guppyLabel = SKSpriteNode(texture: FishTextures.guppySmallSwim.first!)
        guppyLabel.size = CGSize(
            width: FishTextures.guppySmallSwim.first!.size().width * 3.5,
            height: FishTextures.guppySmallSwim.first!.size().height * 3.5,
        )
        guppyLabel.zPosition = 1
        guppyLabel.position = CGPoint(x: 0, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$100"
        label.zPosition = 1
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        buyGuppyButton.addChild(guppyLabel)
        buyGuppyButton.addChild(label)
        addChild(buyGuppyButton)
    }
    
    func addBuyCarnivoreButton() {
        buyCarnivoreButton.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        buyCarnivoreButton.position = CGPoint(x: size.width - 725, y: size.height - 85)
        buyCarnivoreButton.name = "buyCarnivore"
        buyCarnivoreButton.zPosition = 1
        
        let carnivoreLabel = SKSpriteNode(texture: FishTextures.carnivoreSwim.first!)
        carnivoreLabel.size = CGSize(
            width: FishTextures.carnivoreSwim.first!.size().width * 2.5,
            height: FishTextures.carnivoreSwim.first!.size().height * 2.5,
        )
        carnivoreLabel.position = CGPoint(x: 0, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$1000"
        label.zPosition = 1
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        buyCarnivoreButton.addChild(carnivoreLabel)
        buyCarnivoreButton.addChild(label)
        addChild(buyCarnivoreButton)
    }

    func addBuyEggButton() {
        buyEggButton.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        buyEggButton.position = CGPoint(x: size.width - 350, y: size.height - 85)
        buyEggButton.name = "buyEgg"
        buyEggButton.zPosition = 1
        
        eggLabel.size = CGSize(
            width: eggLabel.size.width * 2.5,
            height: eggLabel.size.height * 2.5
        )
        eggLabel.position = CGPoint(x: 0, y: 20)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$\(config.eggPrice)"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        buyEggButton.addChild(eggLabel)
        buyEggButton.addChild(label)
        addChild(buyEggButton)
    }
    
    func addUpgradeFoodButton() {
        upgradeFoodQuality.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        upgradeFoodQuality.position = CGPoint(x: 275, y: size.height - 85)
        upgradeFoodQuality.name = "upgradeQuality"
        upgradeFoodQuality.zPosition = 1
        
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.size = CGSize(
            width: arrow.size.width * 3.5,
            height: arrow.size.width * 3.5
        )
        arrow.position = CGPoint(x: 0, y: 15)
        
        foodUpgradeLabel1.size = CGSize (
            width: foodUpgradeLabel1.size.width * 3.0,
            height: foodUpgradeLabel2.size.height * 3.0
        )
        foodUpgradeLabel1.position = CGPoint(x: -40, y: 15)
        
        foodUpgradeLabel2.size = CGSize (
            width: foodUpgradeLabel2.size.width * 3.0,
            height: foodUpgradeLabel2.size.height * 3.0
        )
        foodUpgradeLabel2.position = CGPoint(x: 40, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$200"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)
        
        upgradeFoodQuality.addChild(arrow)
        upgradeFoodQuality.addChild(foodUpgradeLabel1)
        upgradeFoodQuality.addChild(foodUpgradeLabel2)
        upgradeFoodQuality.addChild(label)
        addChild(upgradeFoodQuality)
    }
    
    func addIncreaseFoodButton() {
        increaseFoodLimit.size = CGSize(width: self.size.width / 8, height: self.size.height / 6)
        increaseFoodLimit.position = CGPoint(x: 460, y: size.height - 85)
        increaseFoodLimit.name = "increaseFoodLimit"
        increaseFoodLimit.zPosition = 1
        
        let foodLabel = SKSpriteNode(texture: ItemTextures.food1)
        foodLabel.size = CGSize(
            width: ItemTextures.food1.size().width * 3.0,
            height: ItemTextures.food1.size().height * 3.0
        )
        foodLabel.position = CGPoint(x: -20, y: 15)
        
        foodLimitLabel.fontSize = 30
        foodLimitLabel.name = "foodLimit"
        foodLimitLabel.verticalAlignmentMode = .center
        foodLimitLabel.horizontalAlignmentMode = .center
        foodLimitLabel.position = CGPoint(x: 20, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$300"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)
        
        increaseFoodLimit.addChild(foodLabel)
        increaseFoodLimit.addChild(foodLimitLabel)
        increaseFoodLimit.addChild(label)
        updateFoodLimitLabel()
        addChild(increaseFoodLimit)
    }
    
    func updateFoodLimitLabel() {
        for node in increaseFoodLimit.children {
            if let label = node as? SKLabelNode,
               label.name == "foodLimit"
            {
                label.text = "x\(state.foodLimit)"
            }
        }
    }
    
    func updateEggLabel() {
        eggLabel.texture = SKTexture(imageNamed: "egg_label_0\(state.eggCount)")
    }
    
    func updateUpgradeFoodLabel() {
        if state.foodQuality == maxQualityUpgrade {
            upgradeFoodQuality.removeAllChildren()
            
            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.fontColor = .white
            label.text = "Max"
            label.fontSize = 35
            label.position = CGPoint(x: 0, y: 0)
            upgradeFoodQuality.addChild(label)
        } else {
            foodUpgradeLabel1.texture = ItemTextures.food2
            foodUpgradeLabel2.texture = ItemTextures.food3
        }
    }
    
    func startLevel() {
        spawnManager.spawnGuppy()
        spawnManager.spawnGuppy()

        hungerTimer?.invalidate()
        
        hungerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            for guppy in self.state.guppyList {
                guppy.update()
            }
            
            for carnivore in self.state.carnivoreList {
                carnivore.update()
            }
        }
                                         
    }
}
