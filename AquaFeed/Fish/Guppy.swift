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

}

class Guppy: Fish {
    
    var guppySize: GuppySize = .small {
        didSet {
            swimSpeed = guppySize.swimSpeed
        }
    }
    
    var growthPoints: Int = 2
    let isStarvingTime: Int = 15
    
    func updateGrowthPoint(numPoints: Int) {
        growthPoints += numPoints
        
        if guppySize == .small {
            if growthPoints > 6 { grow() }
        } else if guppySize == .medium {
            if growthPoints > 12 { grow() }
        }
    }
    
    func grow() {
        switch guppySize {
        case .small:
            guppySize = .medium
            swimTextures = guppySize.swimTextures
            turnTextures = guppySize.turnTextures
            setFishScale(texture: guppySize.swimTextures.first!, scale: 2.0)
            startSwimming()
        case .medium:
            guppySize = .large
            moneyDrop = MoneyType.silver
            swimTextures = guppySize.swimTextures
            turnTextures = guppySize.turnTextures
            setFishScale(texture: guppySize.swimTextures.first!, scale: 2.0)
            startSwimming()
        case .large:
            moneyDrop = MoneyType.gold
            break
        }
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
}
