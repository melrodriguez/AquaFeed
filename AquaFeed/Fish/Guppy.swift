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
            size = CGSize(width: 40, height: 40)
        case .medium:
            guppySize = .large
            size = CGSize(width: 60, height: 60)
            moneyDrop = MoneyType.silver
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
            swimTextures = FishTextures.sickGuppySmallSwim
            turnTextures = FishTextures.sickGuppySmallTurn
            startSwimming()
            isHungry = true
        }
        
        if isHungry && hunger > isStarvingTime {
            swimTextures = FishTextures.guppySmallSwim
            turnTextures = FishTextures.guppySmallTurn
            startSwimming()
            isHungry = false
        }
    }
}
