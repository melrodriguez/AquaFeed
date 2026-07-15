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
//    print(atlas)
//    print(atlas.textureNames)
    
    //print(prefix)
    let names = atlas.textureNames
            .filter { $0.hasPrefix(prefix) }
            .sorted()

//        print("Found \(names.count) textures:")
//        names.forEach { print($0) }

        return names.map { atlas.textureNamed($0) }
//    atlas.textureNames
//        .filter { $0.hasPrefix(prefix) }
//        .sorted()
//        .map { atlas.textureNamed($0) }
}
