//
//  ItemTextures.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/15/26.
//

import SpriteKit

enum ItemTextures {
    static let itemAtlas = SKTextureAtlas(named: "Items")
    
    static let silverCoin = itemAtlas.textureNamed("silver_coin")
    static let goldCoin = itemAtlas.textureNamed("gold_coin")
    static let diamond = itemAtlas.textureNamed("diamond")
    static let pearl = itemAtlas.textureNamed("pearl")
    
    static let food1 = itemAtlas.textureNamed("food_01")
    static let food2 = itemAtlas.textureNamed("food_02")
    static let food3 = itemAtlas.textureNamed("food_03")
    
    static let gun = itemAtlas.textureNamed("gun")
}
