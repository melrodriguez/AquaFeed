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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if let button = node as? LevelButton {
                if button.level == 1 && button.isUnlocked {
                    startLevel(config: LevelConfigs.level1)
                } else if button.level == 2 && button.isUnlocked {
                    startLevel(config: LevelConfigs.level2)
                }
                    
            }
        }
    }
    
    func startLevel(config: LevelConfig) {
        guard let view = self.view else { return }
        
        let levelScene = LevelScene(size: size)
        levelScene.setupConfig(config)
        let transition = SKTransition.fade(with: .black, duration: 1)
        view.presentScene(levelScene, transition: transition)
    }
}
