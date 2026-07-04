//
//  Fish.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/4/26.
//

import SpriteKit
import SwiftUI

class Fish: SKSpriteNode {
    var state: FishState = .wander
    var swimSpeed: CGFloat { 100 }
    
    var sceneWidth: CGFloat {
        self.scene?.size.width ?? 0
    }
    
    var sceneHeight: CGFloat {
        self.scene?.size.height ?? 0
    }
    
    var maxX: CGFloat {
        sceneWidth
    }
    
    var maxY: CGFloat {
        sceneHeight * 0.70
    }
    
    var centerX: CGFloat {
        sceneWidth / 2
    }
    
    var centerY: CGFloat {
        sceneHeight / 2
    }

    func startState() {
        enterWanderState()
    }
    
    func enterPauseState() {
        state = .pause
        
        
        let up = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        let down = SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        
        up.timingMode = .easeInEaseOut
        down.timingMode = .easeInEaseOut
        
        let bob = SKAction.sequence([up, down])
        let loopBob = SKAction.repeatForever(bob)
        
        run(loopBob, withKey: "bob")
        
        let wait = SKAction.wait(forDuration: Double.random(in: 0.5 ... 2.0))
        
        run(wait) { [weak self] in
            guard let self = self else {return}
            self.removeAction(forKey: "bob")
            self.enterWanderState()
        }
    }
    
    func enterWanderState() {
        state = .wander
        
        var target = getWanderLocation()
        
        while getDistance(from: position, to: target) < 100 {
            target = getWanderLocation()
        }
        
        let distance = getDistance(from: position, to: target)
        
        let duration = TimeInterval(distance / swimSpeed)
        
        
        let moveAction = SKAction.move(to: target,
                                       duration: duration)
        
        run(moveAction) { [weak self] in
            self?.enterPauseState()
        }
    }
    
    func getWanderLocation() -> CGPoint {
        let minHeight =  (sceneHeight - maxY) / 2
        let maxHeight = ((sceneHeight - maxY) / 2) + maxY
        let wanderWidth = sceneWidth - 100
        let wanderHeight = maxHeight - minHeight
        
        let halfWidth = wanderWidth / 2
        let halfHeight = wanderHeight / 2
        
        let edge = Int.random(in: 1...4)
        
        switch edge {
        case 1: // Left
            return CGPoint(
                x: centerX - halfWidth,
                y: CGFloat.random(in: (centerY - halfHeight)...(centerY + halfHeight))
            )

        case 2: // Right
            return CGPoint(
                x: centerX + halfWidth,
                y: CGFloat.random(in: (centerY - halfHeight)...(centerY + halfHeight))
            )

        case 3: // Top
            return CGPoint(
                x: CGFloat.random(in: (centerX - halfWidth)...(centerX + halfWidth)),
                y: centerY + halfHeight
            )

        case 4: // Bottom
            return CGPoint(
                x: CGFloat.random(in: (centerX - halfWidth)...(centerX + halfWidth)),
                y: centerY - halfHeight
            )

        default:
            return CGPoint(x: centerX, y: centerY)
        }
    }
    
    func getDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        return sqrt(dx * dx + dy * dy)
    }
}
