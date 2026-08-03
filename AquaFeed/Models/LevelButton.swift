import SpriteKit

class LevelButton: SKSpriteNode {
    let level: Int
    let isUnlocked: Bool
    private let label = SKLabelNode(fontNamed: "Menlo-Bold")
    
    init(level: Int, isUnlocked: Bool) {
        self.level = level
        self.isUnlocked = isUnlocked
        
        if isUnlocked {
             super.init(
                texture: SKTexture(imageNamed: "level_button"),
                color: .clear,
                size: CGSize(width: 100, height: 100)
             )
        } else {
            super.init(
               texture: SKTexture(imageNamed: "locked_level"),
               color: .clear,
               size: CGSize(width: 100, height: 100)
            )
        }
        
        label.text = "\(level)"
        label.fontSize = 50
        label.color = SKColor(
            red: 0xDE / 255.0,
            green: 0xD4 / 255.0,
            blue: 0xC8 / 255.0,
            alpha: 1.0
        )
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        addChild(label)
        
        if !isUnlocked {
            label.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
