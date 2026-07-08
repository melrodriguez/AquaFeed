//
//  TutorialScene.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/6/26.
//

import SwiftUI
import SpriteKit

class TutorialScene: LevelScene {
    var firstFishGrow: Bool = false
    var hasShownMessage: Bool = false
    var tutorialStep: Int = 0
    var shownEggMessage: Bool = false
    var tutorialLabel = SKLabelNode(fontNamed: "Chalkduster")
    var showTextDuration = 2.0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addTutorialLabel()
        startTutorialText()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if firstFishGrow && !hasShownMessage {
            run(SKAction.sequence([
                SKAction.run {
                    self.showText("Your fish has grown! Good Work!")
                    self.buyFishButton.isHidden = false
                    self.hasShownMessage = true
                },
                SKAction.wait(forDuration: showTextDuration),
                SKAction.run { self.showText("You can only drop 1 food pellet at a time for now.") },
                SKAction.wait(forDuration: showTextDuration),
                SKAction.run { self.showText("Make sure you tap the coins for extra money!") },
                SKAction.wait(forDuration: showTextDuration),
                SKAction.run {
                    self.tutorialLabel.isHidden = true
                    self.tutorialStep += 1
                }
            ]))
        }
        
        if tutorialStep == 2 && !shownEggMessage{
            run(SKAction.sequence([
                SKAction.wait(forDuration: 20),
                SKAction.run {
                    self.buyEggButton.isHidden = false
                    self.eggCountLabel.isHidden = false
                    self.showText("Buy 3 egg pieces to complete level!")
                    self.shownEggMessage = true
                },
                SKAction.wait(forDuration: showTextDuration),
                SKAction.run {
                    self.tutorialLabel.isHidden = true
                    self.tutorialStep += 1
                }
            ]))
        }
    }
    
    override func fishFed(_ food: Food, _ guppy: Guppy) {
        super.fishFed(food, guppy)
        
        if guppy.guppySize == .medium && !firstFishGrow {
            firstFishGrow = true
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        // Make these hidden for the tutorial
        eggCountLabel.isHidden = true
        buyFishButton.isHidden = true
        buyEggButton.isHidden = true
        upgradeFoodQuality.isHidden = true
        increaseFoodLimit.isHidden = true
        buyPiranhaButton.isHidden = true
    }
    
    func addTutorialLabel() {
        tutorialLabel.fontSize = 30
        tutorialLabel.fontColor = .green
        tutorialLabel.position = CGPoint(x: size.width / 2, y: 50)
        tutorialLabel.verticalAlignmentMode = .center
        tutorialLabel.horizontalAlignmentMode = .center
        
        addChild(tutorialLabel)
    }
    
    func startTutorialText() {
        run(SKAction.sequence([
            SKAction.run {
                self.showText("Welcome to AquaFeed!")
                self.tutorialStep += 1
            },
            SKAction.wait(forDuration: showTextDuration),
            SKAction.run { self.showText("Here are your first fish! Take good care of them!")},
            SKAction.wait(forDuration: showTextDuration),
            SKAction.run { self.tutorialLabel.isHidden = true }
        ]))
    }
    
    func showText(_ text: String) {
        tutorialLabel.text = text
        tutorialLabel.isHidden = false
    }
}
