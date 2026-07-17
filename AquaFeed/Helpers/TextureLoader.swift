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
    let names = atlas.textureNames
            .filter { $0.hasPrefix(prefix) }
            .sorted()
        return names.map { atlas.textureNamed($0) }
}
