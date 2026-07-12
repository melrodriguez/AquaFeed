//
//  FishTextures.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/11/26.
//

import SpriteKit

enum FishTextures {
    static let guppyAtlas = SKTextureAtlas(named: "Guppy")
    
    static let guppySmallSwim = textures(from: guppyAtlas, prefix: "guppy_small_swim")
    static let guppySmallTurn = textures(from: guppyAtlas, prefix: "guppy_small_turn")
    static let guppySmallEat = textures(from: guppyAtlas, prefix: "guppy_small_eat")
}
