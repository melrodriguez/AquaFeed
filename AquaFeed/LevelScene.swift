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
    var boundary = SKSpriteNode(color: .red,
                                size: CGSize(width: 1376, height: 750))
    var maxX: CGFloat {
        size.width
    }
    
    var maxY: CGFloat {
        size.height * 0.70
    }
    
    var centerX: CGFloat {
        size.width / 2
    }
    
    var centerY: CGFloat {
        size.height / 2
    }
    
    var pauseDuration = 1.0;
    
    var gameOver = false
    var gameTimer: Timer?
    var guppy = Guppy(color: .orange, size: CGSize(width: 30, height: 30))

    override func didMove(to view: SKView) {
        setupBackground()
        setupBoundary()
        setupLevelLabel()
        spawnGuppy()
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupBoundary() {
        boundary.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(boundary)
    }
    
    func spawnGuppy() {
        // TODO: REPLACE WITH VARIABLES HERE
        let minHeight =  (size.height - 750) / 2
        let maxHeight = ((size.height - 750) / 2) + 750

        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomY = CGFloat.random(in: minHeight...maxHeight)
        // TODO: GO BACK TO RANDOM POINTS

        guppy.position = CGPoint(x: centerX, y: centerY)
        addChild(guppy)
        guppy.startState()
        
    }
    
    func setupLevelLabel() {
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        levelLabel.fontSize = 100
        levelLabel.fontColor = .white
        levelLabel.text = "Level 1"
        addChild(levelLabel)
    }
}
