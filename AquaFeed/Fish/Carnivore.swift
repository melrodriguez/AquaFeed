//
//  Carnivore.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/10/26.
//

import SwiftUI
import SpriteKit

class Carnivore: Fish {
    let isStarvingTime: Int = 20

    override func update() {
        super.update()
        
        if hunger <= isStarvingTime && !isHungry {
            swimTextures = FishTextures.sickCarnivoreSwim
            turnTextures = FishTextures.sickCarnivoreTurn
            startSwimming()
            isHungry = true
        }
        
        if isHungry && hunger > isStarvingTime {
            swimTextures = FishTextures.carnivoreSwim
            turnTextures = FishTextures.carnivoreTurn
            startSwimming()
            isHungry = false
        }
    }
    
    override func animateEat() {
        removeAction(forKey: "animation")
        
        let eat = SKAction.animate(
            with: eatTextures,
            timePerFrame: 0.06
        )
        
        run(eat) { [weak self] in
            guard let self = self else { return }
            self.startState()
        }
    }
}
