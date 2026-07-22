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
    
    override func findNearestFood() -> SKSpriteNode? {
        let detectionRangeFish: CGFloat = 1000
        
        return GameState.shared.guppyList
            .filter { $0.guppySize == .small}
            .filter {
                getDistance(from: position, to: $0.position) <=
                    detectionRangeFish
            }
            .min {
                getDistance(from: position, to: $0.position) <
                getDistance(from: position, to: $1.position)
            }
    }
}
