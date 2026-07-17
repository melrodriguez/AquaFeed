//
//  Food.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/7/26.
//

import SwiftUI
import SpriteKit

enum FoodQuality {
    case level1
    case level2
    case level3
    
    var refillValue: Int {
        switch self {
        case.level1:
            return 11
        case.level2:
            return 18
        case.level3:
            return 29
        }
    }
    
    var growthPoints: Int {
        switch self {
        case.level1:
            return 1
        case.level2:
            return 2
        case.level3:
            return 3
        }
    }
    
    var texture: SKTexture {
        switch self {
        case.level1:
            return ItemTextures.food1
        case.level2:
            return ItemTextures.food2
        case.level3:
            return ItemTextures.food3
        }
    }
    
    var scale: CGFloat {
        switch self {
        case.level1:
            return 2.5
        case.level2:
            return 3.0
        case.level3:
            return 4.0
        }
    }
}

class Food: SKSpriteNode {
    var quality: FoodQuality
    
    init(quality: FoodQuality) {
        self.quality = quality
        super.init(
            texture: quality.texture,
            color: .clear,
            size: CGSize(
                width: quality.texture.size().width * quality.scale,
                height: quality.texture.size().height * quality.scale
            )
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

