import SpriteKit
import SwiftUI

class LevelSelectionScene: SKScene {
    var background = SKSpriteNode(imageNamed: "level_selection_background")
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupLevelButtons()
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        
        let texture = SKTexture(imageNamed: "select_level_label")
        texture.filteringMode = .nearest
        let level_selection_label = SKSpriteNode(texture: texture)
        level_selection_label.setScale(8.0)
        level_selection_label.position = CGPoint(x: size.width / 2, y: size.height - 150)
        addChild(level_selection_label)
    }
    
    func setupLevelButtons() {
        var xPos = 250
        let yPos = 650
        
        for level in 1...5 {
            let index = level - 1
            let button = LevelButton(level: level, isUnlocked: GameState.shared.levels[index].unlocked)
            button.position = CGPoint(x: xPos, y: yPos)
            addChild(button)
            xPos += 200
        }
        
    }
}
