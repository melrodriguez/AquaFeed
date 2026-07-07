//
//  EndLevel.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/6/26.
//

import SwiftUI
import SpriteKit

class EndScene: SKScene {
    var background = SKSpriteNode(imageNamed: "aquarium")
    var gameEndedLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    var maxWidth: CGFloat {
        size.width
    }
    
    var maxHeight: CGFloat {
        size.height * 0.70
    }
    
    var groundY: CGFloat {
        (size.height - maxHeight) / 2 - 20
    }
    
    var centerX: CGFloat {
        size.width / 2
    }
    
    var centerY: CGFloat {
        size.height / 2
    }
    
    override func didMove(to view: SKView) {
        setupBackground()
        addGameEndedText()
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func addGameEndedText() {
        gameEndedLabel.fontColor = .white
        gameEndedLabel.position = CGPoint(x: size.width / 2, y: size.width / 2)
        gameEndedLabel.fontSize = 50
        gameEndedLabel.verticalAlignmentMode = .center
        gameEndedLabel.horizontalAlignmentMode = .center
        gameEndedLabel.text = "Yay, you completed the tutorial"
        addChild(gameEndedLabel)
    }

}
