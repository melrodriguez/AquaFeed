import SpriteKit

enum MenuButtonType {
    case buyGuppy
    case buyEgg
    case buyFoodQualityUpgrade
    case buyFoodLimitIncrease
    case buyCarnivore
    case buyLaserUpgrade
    
    var price: Int {
        switch self {
        case .buyGuppy:
            return 100
        case .buyEgg:
            return 0
        case .buyFoodQualityUpgrade:
            return 200
        case .buyFoodLimitIncrease:
            return 300
        case .buyCarnivore:
            return 1000
        case .buyLaserUpgrade:
            return 1000
        }
    }
    
    var name: String {
        switch self {
        case .buyGuppy:
            return "buyGuppy"
        case .buyEgg:
            return "buyEgg"
        case .buyFoodQualityUpgrade:
            return "buyFoodQualityUpgrade"
        case .buyFoodLimitIncrease:
            return "buyFoodLimitIncrease"
        case .buyCarnivore:
            return "buyCarnivore"
        case .buyLaserUpgrade:
            return "buyLaserUpgrade"
        }
    }
}

class MenuButton: SKSpriteNode {
    let price: Int?
    let buttonType: MenuButtonType
    
    private let label = SKLabelNode(fontNamed: "Menlo-Bold")
    
    init(buttonType: MenuButtonType, price: Int?, size: CGSize) {
        self.buttonType = buttonType
        
        if buttonType == MenuButtonType.buyEgg {
            self.price = price
        } else {
            self.price = nil
        }
        
        super.init(
           texture: SKTexture(imageNamed: "menu_board"),
           color: .clear,
           size: size
        )
        
        name = buttonType.name
        zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructButton() {
        switch buttonType {
        case .buyGuppy:
            constructBuyGuppyButton()
        case .buyEgg:
            constructBuyEggButton()
        case .buyFoodQualityUpgrade:
            constructBuyFoodQualityUpgradeButton()
        case .buyFoodLimitIncrease:
            constructBuyFoodLimitIncreaseButton()
        case .buyCarnivore:
            constructBuyCarnivoreButton()
        case .buyLaserUpgrade:
            constructBuyLaserUpgrade()
        }
    }
    
    private func constructBuyGuppyButton() {
        let guppyLabel = SKSpriteNode(texture: FishTextures.guppySmallSwim.first!)
        guppyLabel.size = CGSize(
            width: FishTextures.guppySmallSwim.first!.size().width * 3.5,
            height: FishTextures.guppySmallSwim.first!.size().height * 3.5,
        )
        guppyLabel.zPosition = 1
        guppyLabel.position = CGPoint(x: 0, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$\(buttonType.price)"
        label.zPosition = 1
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        addChild(guppyLabel)
        addChild(label)
    }
    
    private func constructBuyEggButton() {
        guard let price = price else { return }
        
        var eggLabel = SKSpriteNode(imageNamed: "egg_label_00")
        eggLabel.size = CGSize(
            width: eggLabel.size.width * 2.5,
            height: eggLabel.size.height * 2.5
        )
        eggLabel.position = CGPoint(x: 0, y: 20)
        eggLabel.name = "eggLabel"
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$\(price)"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)

        addChild(eggLabel)
        addChild(label)
    }
    
    private func constructBuyFoodQualityUpgradeButton() {
        let arrow = SKSpriteNode(imageNamed: "arrow")
        let foodUpgradeLabel1 = SKSpriteNode(texture: ItemTextures.food1)
        let foodUpgradeLabel2 = SKSpriteNode(texture: ItemTextures.food2)
        
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
        foodUpgradeLabel1.name = "foodUpgradeLabel1"
        
        foodUpgradeLabel2.size = CGSize (
            width: foodUpgradeLabel2.size.width * 3.0,
            height: foodUpgradeLabel2.size.height * 3.0
        )
        foodUpgradeLabel2.position = CGPoint(x: 40, y: 15)
        foodUpgradeLabel2.name = "foodUpgradeLabel2"

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$\(buttonType.price)"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)
        
        addChild(arrow)
        addChild(foodUpgradeLabel1)
        addChild(foodUpgradeLabel2)
        addChild(label)
    }
    
    private func constructBuyFoodLimitIncreaseButton() {
        let foodLabel = SKSpriteNode(texture: ItemTextures.food1)
        foodLabel.size = CGSize(
            width: ItemTextures.food1.size().width * 3.0,
            height: ItemTextures.food1.size().height * 3.0
        )
        foodLabel.position = CGPoint(x: -20, y: 15)
        
        let foodLimitLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        foodLimitLabel.fontSize = 30
        foodLimitLabel.name = "foodLimit"
        foodLimitLabel.verticalAlignmentMode = .center
        foodLimitLabel.horizontalAlignmentMode = .center
        foodLimitLabel.position = CGPoint(x: 20, y: 15)
        
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "$\(buttonType.price)"
        label.fontSize = 30
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -40)
        
        addChild(foodLabel)
        addChild(foodLimitLabel)
        addChild(label)
    }
    
    private func constructBuyCarnivoreButton() {
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

        addChild(carnivoreLabel)
        addChild(label)
    }
    
    private func constructBuyLaserUpgrade() {
        let laserLabel = SKSpriteNode(texture: ItemTextures.gun)
        laserLabel.size = CGSize(
            width: ItemTextures.gun.size().width * 3.0,
            height: ItemTextures.gun.size().height * 3.0
        )
        laserLabel.position = CGPoint(x: -25, y: 15)
        
        let priceLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        priceLabel.text = "$\(buttonType.price)"
        priceLabel.verticalAlignmentMode = .center
        priceLabel.horizontalAlignmentMode = .center
        priceLabel.position = CGPoint(x: 0, y: -40)
        
        var upgradeLaserLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        upgradeLaserLabel.text = "x\(1)"
        upgradeLaserLabel.name = "laserLevel"
        upgradeLaserLabel.verticalAlignmentMode = .center
        upgradeLaserLabel.horizontalAlignmentMode = .center
        upgradeLaserLabel.position = CGPoint(x: 25, y: 15)
        
        addChild(laserLabel)
        addChild(priceLabel)
        addChild(upgradeLaserLabel)
    }
    
    func upgradeEggButton(eggCount: Int) {
        if buttonType != MenuButtonType.buyEgg { return }
        
        if let sprite = childNode(withName: "eggLabel") as? SKSpriteNode {
            sprite.texture = SKTexture(imageNamed: "egg_label_0\(eggCount)")
        }
    }
}
