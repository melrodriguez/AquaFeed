//
//  FishTextures.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/11/26.
//

import SpriteKit

enum FishTextures {
    static let smallGuppyAtlas = SKTextureAtlas(named: "SmallGuppy")
    static let medGuppyAtlas = SKTextureAtlas(named: "MediumGuppy")
    static let bigGuppyAtlas = SKTextureAtlas(named: "LargeGuppy")
    static let carnivoreAtlas = SKTextureAtlas(named: "Carnivore")
    
    static let guppySmallSwim = textures(from: smallGuppyAtlas, prefix: "guppy_small_swim")
    static let guppySmallTurn = textures(from: smallGuppyAtlas, prefix: "guppy_small_turn")
    static let guppySmallEat = textures(from: smallGuppyAtlas, prefix: "guppy_small_eat")
    static let sickGuppySmallSwim = textures(from: smallGuppyAtlas, prefix: "sick_guppy_small_swim")
    static let sickGuppySmallTurn = textures(from: smallGuppyAtlas, prefix: "sick_guppy_small_turn")
    static let guppySmallDead = textures(from: smallGuppyAtlas, prefix: "guppy_small_dead")
    
    static let guppyMedSwim = textures(from: medGuppyAtlas, prefix: "guppy_med_swim")
    static let guppyMedTurn = textures(from: medGuppyAtlas, prefix: "guppy_med_turn")
    static let guppyMedEat = textures(from: medGuppyAtlas, prefix: "guppy_med_eat")
    static let sickGuppyMedSwim = textures(from: medGuppyAtlas, prefix: "sick_guppy_med_swim")
    static let sickGuppyMedTurn = textures(from: medGuppyAtlas, prefix: "sick_guppy_med_turn")
    static let guppyMedDead = textures(from: medGuppyAtlas, prefix: "guppy_med_dead")

    static let guppyBigSwim = textures(from: bigGuppyAtlas, prefix: "guppy_big_swim")
    static let guppyBigTurn = textures(from: bigGuppyAtlas, prefix: "guppy_big_turn")
    static let guppyBigEat = textures(from: bigGuppyAtlas, prefix: "guppy_big_eat")
    static let sickGuppyBigSwim = textures(from: bigGuppyAtlas, prefix: "sick_guppy_big_swim")
    static let sickGuppyBigTurn = textures(from: bigGuppyAtlas, prefix: "sick_guppy_big_turn")
    static let guppyBigDead = textures(from: bigGuppyAtlas, prefix: "guppy_big_dead")
    
    static let carnivoreSwim = textures(from: carnivoreAtlas, prefix: "carnivore_swim")
    static let carnivoreTurn = textures(from: carnivoreAtlas, prefix: "carnivore_turn")
    static let carnivoreEat = textures(from: carnivoreAtlas, prefix: "carnivore_eat")
    static let sickCarnivoreSwim = textures(from: carnivoreAtlas, prefix: "sick_carnivore_swim")
    static let sickCarnivoreTurn = textures(from: carnivoreAtlas, prefix: "sick_carnivore_turn")
    static let carnivoreDead = textures(from: carnivoreAtlas, prefix: "carnivore_dead")
}
