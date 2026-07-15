//
//  Money.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/5/26.
//

import SwiftUI
import SpriteKit

enum MoneyType {
    case silver
    case gold
    case diamond
    
    var value: Int {
        switch self {
        case.silver:
            return 15
        case.gold:
            return 35
        case.diamond:
            return 200
        }
    }
    
    var texture: SKTexture {
        switch self {
        case.silver:
            return ItemTextures.silverCoin
        case.gold:
            return ItemTextures.goldCoin
        case.diamond:
            return ItemTextures.diamond
        }
    }
    
    var size: CGSize {
        switch self {
        case.silver: return CGSize(width: 30, height: 30)
        case.gold: return CGSize(width: 30, height: 30)
        case.diamond: return CGSize(width: 40, height: 40)
        }
    }
}

class Money: SKSpriteNode {
    var type: MoneyType
    
    init(type: MoneyType) {
        self.type = type
        super.init(
            texture: type.texture,
            color: .clear,
            size: CGSize(
                width: type.texture.size().width,
                height: type.texture.size().height
            )
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

