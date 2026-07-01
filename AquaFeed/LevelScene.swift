//
//  LevelScene.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/1/26.
//

import SpriteKit
import SwiftUI

class LevelScene: SKScene {
    var background = SKSpriteNode(imageNamed: "aquarium")
    var levelLabel = SKLabelNode(fontNamed: "Chalkduster")
    var gameOver = false
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupLevelLabel()
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func spawnGuppy() {
        var guppy = SKSpriteNode(imageNamed: "guppy")
        
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomY = CGFloat.random(in: 100...size.width - 100)
        
        guppy.position = CGPoint(x: randomX, y: randomY)
             
    }
    
    func setupLevelLabel() {
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        levelLabel.fontSize = 100
        levelLabel.fontColor = .white
        levelLabel.text = "Level 1"
        addChild(levelLabel)
    }
}
