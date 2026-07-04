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
}

class Guppy: Fish {
    
    var guppySize: GuppySize = .small
    override var swimSpeed: CGFloat { 300 }
    
}
