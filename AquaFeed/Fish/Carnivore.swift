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
        updateAppearance()
    }
    
    func updateAppearance() {
        if hunger <= isStarvingTime {
            swimTextures = FishTextures.sickCarnivoreSwim
            turnTextures = FishTextures.sickCarnivoreTurn
            showingHungryVisual = true
            startSwimming()
        } else {
            if showingHungryVisual {
                swimTextures = FishTextures.carnivoreSwim
                turnTextures = FishTextures.carnivoreTurn
                showingHungryVisual = false
                startSwimming()
            }
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
            self.updateAppearance()
            self.startState()
        }
    }
}
