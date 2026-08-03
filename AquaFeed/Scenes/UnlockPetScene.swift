import SpriteKit
import SwiftUI

class UnlockPetScene: SKScene {
    var background = SKSpriteNode(imageNamed: "level_selection_background")
    var pet: PetInfo
    var levelConfig: LevelConfig?
    var onContinue: (() -> Void)?

    init(size: CGSize, pet: PetInfo) {
        self.pet = pet
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        addUnlockLabel()
        displayPet()
        addContinueButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        for node in nodes(at: location) {
            if node.name == "continue" {
                onContinue?()
            }
        }
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func addUnlockLabel() {
        let texture = SKTexture(imageNamed: "you_unlocked")
        texture.filteringMode = .nearest
        let level_selection_label = SKSpriteNode(texture: texture)
        level_selection_label.setScale(8.0)
        level_selection_label.position = CGPoint(x: size.width / 2, y: size.height - 150)
        addChild(level_selection_label)
    }
    
    func displayPet() {
        let petSprite = SKSpriteNode(texture: pet.texture)
        petSprite.setScale(4.0)
        petSprite.position = CGPoint(
            x: self.size.width / 2,
            y: self.size.height / 2
        )
        
        let fullText = pet.type.displayName
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = ""
        label.fontSize = 60
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        label.position = CGPoint(
            x: self.size.width / 2,
            y: self.size.height / 2 - 200
        )
        
        addChild(petSprite)
        addChild(label)
        
        petSprite.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        petSprite.run(fadeIn)
        
        for (index, character) in fullText.enumerated() {
            let wait = SKAction.wait(forDuration: Double(index) * 0.07)
            let type = SKAction.run {
                label.text! += String(character)
            }
            
            run(.sequence([wait, type]))
        }
    }
    
    func addContinueButton() {
        let texture = SKTexture(imageNamed: "continue")
        texture.filteringMode = .nearest
        let continue_label = SKSpriteNode(texture: texture)
        continue_label.name = "continue"
        continue_label.setScale(7.0)
        continue_label.position = CGPoint(x: size.width / 2, y: size.height / 2 - 350)
        addChild(continue_label)
    }
    
}
