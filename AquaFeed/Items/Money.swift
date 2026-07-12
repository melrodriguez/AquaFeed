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
    
    var color: UIColor {
        switch self {
        case.silver: return .lightGray
        case.gold: return .yellow
        case.diamond: return .blue
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
        super.init(texture: nil, color: type.color, size: type.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

