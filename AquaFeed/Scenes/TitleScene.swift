//
//  TitleScene.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/1/26.
//

import SpriteKit
import SwiftUI

class TitleScene: SKScene {
    var background = SKSpriteNode(imageNamed: "aquarium")
    var gameLabel = SKSpriteNode(imageNamed: "aquafeed")
    var playButton = SKSpriteNode(imageNamed: "playButton0")
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupGameLabel()
        setupPlayButton()
    }
    
    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupGameLabel() {
        gameLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        gameLabel.setScale(2.0)
        addChild(gameLabel)
    }
    
    func setupPlayButton() {
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        playButton.setScale(4.0)
        playButton.name = "playButton"
        addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let node = atPoint(location)
        
        if node.name == "playButton" || node.parent?.name == "playButton" {
            guard let view = self.view else { return }
            
//            let levelScene = LevelScene(size: size)
//            levelScene.setupConfig(Levels.level1)
//            let transition = SKTransition.fade(with: .black, duration: 1)
//            view.presentScene(levelScene, transition: transition)
            let tutorialScene = TutorialScene(size: size)
            tutorialScene.setupConfig(Levels.level1)
            let transition = SKTransition.fade(with: .black, duration: 1)
            view.presentScene(tutorialScene, transition: transition)
        }
    }
}
