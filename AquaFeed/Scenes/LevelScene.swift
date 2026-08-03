import SpriteKit
import SwiftUI

let despawnTime = 1.5
let guppyPrice = 100
let carnivorePrice = 1000
let upgradeFoodQualityCost = 200
let increaseFoodLimitCost = 300
let laserUpgradePrice = 1000
let eggLimit = 3
let maxQualityUpgrade = FoodQuality.level3

class LevelScene: SKScene, SKPhysicsContactDelegate {
    var config: LevelConfig
    var background = SKSpriteNode(imageNamed: "aquarium")
    var menu = SKSpriteNode(imageNamed: "menu")
    var walletLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
    var ground = SKNode()
    lazy var spawnManager = SpawnManager(scene: self)
    
    var maxHeight: CGFloat {
        size.height * 0.70
    }
    
    var groundY: CGFloat {
        (size.height - maxHeight) / 2 - 20
    }
    
    var pauseDuration = 1.0;
    let state = LevelState.shared
    
    var gameTimer: Timer?
    var onComplete: (() -> Void)?
    var onPause: (() -> Void)?
    var onDied: (() -> Void)?
    var longPressTimer: Timer?
    var isLongPress: Bool = false
    var petsToSpawn: [PetType]
    var isGamePaused: Bool = false

    init(size: CGSize, config: LevelConfig, petsToSpawn: [PetType]) {
        self.config = config
        self.petsToSpawn = petsToSpawn
        super.init(size: size)
        setupConfig(config)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
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
        isLongPress = false
        
        longPressTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false
        ) { [weak self] _ in
            self?.isLongPress = true
            self?.isPaused = true
            self?.isGamePaused = true
            self?.onPause?()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        longPressTimer = nil
        
        if isLongPress {
            return
        }
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if let money = node as? Money {
                if let body = money.physicsBody {
                    if body.categoryBitMask == PhysicsCategory.money {
                        state.updateWallet(amount: money.type.value)
                        updateWalletLabel()
                        money.setMoneyAsCollected()
                        money.removeFromParent()
                        state.removeMoney(money)
                        return
                    }
                }
            }
            
            if let alien = node as? Alien {
                if alien.isDead { return }
                alien.decreaseHealth(damage: state.laserDamage)
                alien.bump(from: location)
            }
            
            if let button = node as? MenuButton {
                handleNodeButton(button)
            }
            
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
    
    private func handleNodeButton(_ button: MenuButton) {
        if button.isHidden { return }
        
        switch button.name {
        case "buyGuppy":
            buyGuppy()
            
        case "buyEgg":
            buyEgg(button)
        
        case "buyFoodQualityUpgrade":
            buyFoodQualityUpgrade(button)
            
        case "buyFoodLimitIncrease":
            buyFoodLimitIncrease(button)
        
        case "buyCarnivore":
            buyCarnivore()
        
        case "buyLaserUpgrade":
            buylaserUpgrade(button)
        
        default:
            break
        }
    }
    
    func buyGuppy() {
        if state.wallet >= guppyPrice {
            state.updateWallet(amount: -guppyPrice)
            spawnManager.spawnGuppy(isBirthed: false)
            updateWalletLabel()
        }
        return
    }
    
    func buyEgg(_ button: MenuButton) {
        if state.wallet >= config.eggPrice {
            state.updateWallet(amount: -config.eggPrice)
            updateWalletLabel()
            state.increaseEggCount()
            button.upgradeEggButton()
        }
        return
    }
    
    func buyFoodQualityUpgrade(_ button: MenuButton) {
        if state.wallet >= upgradeFoodQualityCost {
            state.updateWallet(amount: -upgradeFoodQualityCost)
            updateWalletLabel()
            state.upgradeFood()
            button.upgradFoodLabel()
        }
    }
    
    func buyFoodLimitIncrease(_ button: MenuButton) {
        if state.wallet >= increaseFoodLimitCost {
            state.updateWallet(amount: -increaseFoodLimitCost)
            updateWalletLabel()
            state.increaseFoodLimit()
            button.increaseFoodCount()
        }
    }
    
    func buyCarnivore() {
        if state.wallet >= carnivorePrice {
            state.updateWallet(amount: -carnivorePrice)
            updateWalletLabel()
            spawnManager.spawnCarnivore()
        }
    }
    
    func buylaserUpgrade(_ button: MenuButton) {
        print("buyLaser")
        if state.wallet >= laserUpgradePrice {
            state.updateWallet(amount: -laserUpgradePrice)
            updateWalletLabel()
            state.upgradeLaser()
            button.upgradeLaserLabel()
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
        
        if state.eggCount == eggLimit {
            completeLevel()
        }
    }
    
    func completeLevel() {
        GameState.shared.setNextLevelUnlocked(currentLevel: config.level)
        onComplete?()
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
                let itchy: Itchy = node(ofType: Itchy.self, from: contact)
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
            
            let runAction = SKAction.run { [weak self, weak item] in
                guard let self, let item else { return }
                
                if isFood {
                    self.state.removeFood(item)
                } else {
                    self.state.removeMoney(item)
                }
                
            }
            
            despawn = SKAction.sequence([
                waitAction,
                runAction,
                .removeFromParent()
            ])
            
            item.run(despawn, withKey: "despawn")
        }
    }
    
    func setupConfig(_ config: LevelConfig) {
        self.config = config
        state.setupLevel(config: config)
        
        if !config.aliens.isEmpty {
            state.setEnemyTimer(time: config.spawnRate)
        }
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
        
        createButtons()
    }
    
    func createButtons() {
        var menuButton: MenuButton
        var xPos: CGFloat = 85
        let yPos = size.height - 85
        let buttonSize = CGSize(
            width: self.size.width / 8,
            height: self.size.height / 6
        )
        
        for button in config.menuButton {
            if button == MenuButtonType.buyEgg {
                menuButton = MenuButton(
                    buttonType: button,
                    price: config.eggPrice,
                    size: buttonSize
                )
            } else {
                menuButton = MenuButton(
                    buttonType: button,
                    price: nil,
                    size: buttonSize
                )
            }
            
            state.buttons.append(menuButton)
            menuButton.position = CGPoint(
                x: xPos,
                y: yPos
            )
            
            xPos += ((self.size.width / 8) + 16)
            addChild(menuButton)
        }
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
    
    func startLevel() {
        for pet in petsToSpawn {
            spawnManager.spawnPet(type: pet)
        }
        
        spawnManager.spawnGuppy(isBirthed: false)
        spawnManager.spawnGuppy(isBirthed: false)

        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard !self.isGamePaused else { return }
            guard !self.state.gameOver else { return }
            
            if !config.aliens.isEmpty {
                state.spawnEnemyTimer -= 1
                state.spawnEnemyTimer = max(state.spawnEnemyTimer, 0)
                
                if state.spawnEnemyTimer == 10 {
                    let label = SKLabelNode(fontNamed: "Menlo-Bold")
                    label.text = "An enemy is approaching!"
                    label.position = CGPoint(x: size.width / 2, y: 50)
                    label.verticalAlignmentMode = .center
                    label.horizontalAlignmentMode = .center
                    addChild(label)
                    
                    let showAndHide = SKAction.sequence([
                        .wait(forDuration: 2.0),
                        .removeFromParent()
                    ])
                    
                    label.run(showAndHide)
                }
                
                if state.spawnEnemyTimer == 0 {
                    for alien in config.aliens {
                        spawnManager.spawnAlien(alienType: alien)
                    }
                    state.setEnemyTimer(time: config.spawnRate)
                }
            }
            
            if state.guppyList.isEmpty && state.carnivoreList.isEmpty {
                state.gameOver = true
                onDied?()
            }
            
            for guppy in self.state.guppyList {
                guppy.update()
            }
            
            for carnivore in self.state.carnivoreList {
                carnivore.update()
            }
            
            if state.alienList.isEmpty {
                for pet in self.state.petList {
                    if let niko = pet as? Niko {
                        niko.update()
                    }
                    
                    if let prego = pet as? Prego {
                        prego.update()
                    }
                }
            }
        }
    }
}
