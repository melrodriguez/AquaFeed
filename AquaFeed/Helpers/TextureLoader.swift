//
//  TextureLoader.swift
//  AquaFeed
//
//  Created by Rodriguez, Melody A on 7/11/26.
//

import SpriteKit

func textures(
    from atlas: SKTextureAtlas,
    prefix: String
) -> [SKTexture] {
    atlas.textureNames
        .filter { $0.hasPrefix(prefix) }
        .sorted()
        .map { atlas.textureNamed($0) }
}
