import SwiftUI
import SpriteKit

enum GuppySize {
    case small
    case medium
    case large
    
    var swimSpeed: CGFloat {
        switch self {
        case.small:
            return 200
        case.medium:
            return 170
        case.large:
            return 140
        }
    }
    
    var swimTextures: [SKTexture] {
        switch self {
        case.small:
            return FishTextures.guppySmallSwim
        case.medium:
            return FishTextures.guppyMedSwim
        case.large:
            return FishTextures.guppyBigSwim
        }
    }
    
    var turnTextures: [SKTexture] {
        switch self {
        case.small:
            return FishTextures.guppySmallTurn
        case.medium:
            return FishTextures.guppyMedTurn
        case.large:
            return FishTextures.guppyBigTurn
        }
    }
    
    var eatTextures: [SKTexture] {
        switch self {
        case.small:
            return FishTextures.guppySmallEat
        case.medium:
            return FishTextures.guppyMedEat
        case.large:
            return FishTextures.guppyBigEat
        }
    }
    
    var sickSwimTextures: [SKTexture] {
        switch self {
        case.small:
            return FishTextures.sickGuppySmallSwim
        case.medium:
            return FishTextures.sickGuppyMedSwim
        case.large:
            return FishTextures.sickGuppyBigSwim
        }
    }
    
    var sickTurnTextures: [SKTexture] {
        switch self {
        case.small:
            return FishTextures.sickGuppySmallTurn
        case.medium:
            return FishTextures.sickGuppyMedTurn
        case.large:
            return FishTextures.sickGuppyBigTurn
        }
    }
    
    var deadTextures: [SKTexture] {
        switch self {
        case.small:
            return FishTextures.guppySmallDead
        case.medium:
            return FishTextures.guppyMedDead
        case.large:
            return FishTextures.guppyBigDead
        }
    }

}

class Guppy: Fish {
    
    var guppySize: GuppySize = .small {
        didSet {
            swimSpeed = guppySize.swimSpeed
            swimTextures = guppySize.swimTextures
            turnTextures = guppySize.turnTextures
            eatTextures = guppySize.eatTextures
            deadTextures = guppySize.deadTextures
        }
    }
    
    var growthPoints: Int = 2
    let isStarvingTime: Int = 15
    
    func updateGrowthPoint(numPoints: Int) {
        growthPoints += numPoints
    }
    
    func canGrow() -> Bool {
        if guppySize == .small || guppySize == .medium {
            if growthPoints > 6 {
                return true
            }
        }
            
        return false
    }
    
    func grow() {
        switch guppySize {
        case .small:
            guppySize = .medium
            moneyDrop = MoneyType.silver
            setFishScale(scale: 2.5)
            hunger = 20
            growthPoints = 0
        case .medium:
            guppySize = .large
            moneyDrop = MoneyType.gold
            setFishScale(scale: 3.0)
            hunger = 20
            growthPoints = 0
        case .large:
            break
        }
    }
    
    override func handleDropCoin() {
        if guppySize == .small { return }
        super.handleDropCoin()
    }
    
    override func update() {
        super.update()
        
        updateAppearance()
    }
    
    func updateAppearance() {
        if hunger <= isStarvingTime {
            swimTextures = guppySize.sickSwimTextures
            turnTextures = guppySize.sickTurnTextures
            showingHungryVisual = true
        } else {
            if showingHungryVisual {
                swimTextures = guppySize.swimTextures
                turnTextures = guppySize.turnTextures
                showingHungryVisual = false
            }
        }
    }
    
    override func animateEat() {
        removeAllActions()
        
        let eat = SKAction.animate(
            with: eatTextures,
            timePerFrame: 0.06
        )
        
        run(eat) { [weak self] in
            guard let self = self else { return }
            if self.canGrow() {
                self.grow()
            } else {
                self.updateAppearance()
            }
            
            self.enterWanderState()
        }
        
        run(SKAction.playSoundFileNamed(
            "eat.mp3",
            waitForCompletion: false
        ))
    }
}
