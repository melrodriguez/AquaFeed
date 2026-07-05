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
    var swimSpeed: CGFloat = 200

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
        let edgeInset: CGFloat = 50
        let maxVerticalChange: CGFloat = 80
        
        let rect = CGRect(
            x: edgeInset,
            y: (sceneHeight - maxY) / 2 + 30,
            width: sceneWidth - edgeInset * 2,
            height: maxY - 50
        )
        
        switch Int.random(in: 0..<4) {
        case 0:
            return CGPoint(
                x: rect.minX,
                y: max(rect.minY,
                       min(rect.maxY,
                           position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                        )
            )
        case 1:
            return CGPoint(
                x: rect.maxX,
                y: max(rect.minY,
                       min(rect.maxY,
                           position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                        )
            )
        case 2:
            return CGPoint(
                x: CGFloat.random(in: rect.minX...rect.maxX),
                y: max(rect.minY,
                       min(rect.maxY,
                           position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                        )
            )
        default:
            return CGPoint(x: CGFloat.random(in: rect.minX...rect.maxX),
                           y: max(rect.minY,
                                  min(rect.maxY,
                                      position.y + CGFloat.random(in: -maxVerticalChange...maxVerticalChange))
                                   )
            )
        }
    }

    func getDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        return sqrt(dx * dx + dy * dy)
    }
}
