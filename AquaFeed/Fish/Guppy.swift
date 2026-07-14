//
//  Guppy.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/4/26.
//

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
    
    func canGrow() {
        if guppySize == .small {
            if growthPoints > 4 { grow() }
        } else if guppySize == .medium {
            if growthPoints > 8 { grow() }
        }
    }
    
    func grow() {
        switch guppySize {
        case .small:
            guppySize = .medium
            moneyDrop = MoneyType.silver
        case .medium:
            guppySize = .large
            moneyDrop = MoneyType.gold
        case .large:
            break
        }
        
        setFishScale(texture: guppySize.swimTextures.first!, scale: 2.0)
    }
    
    override func handleDropCoin() {
        if guppySize == .small { return }
        super.handleDropCoin()
    }
    
    override func update() {
        super.update()
        
        if hunger <= isStarvingTime && !isHungry {
            swimTextures = guppySize.sickSwimTextures
            turnTextures = guppySize.sickTurnTextures
            startSwimming()
            isHungry = true
        }
        
        if isHungry && hunger > isStarvingTime {
            swimTextures = guppySize.swimTextures
            turnTextures = guppySize.turnTextures
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
            self.canGrow()
            self.startSwimming()
            self.enterWanderState()
        }
    }
}
