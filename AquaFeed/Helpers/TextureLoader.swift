import SpriteKit

func textures(
    from atlas: SKTextureAtlas,
    prefix: String
) -> [SKTexture] {
    let names = atlas.textureNames
            .filter { $0.hasPrefix(prefix) }
            .sorted()
    
    print(names)
    
        return names.map { atlas.textureNamed($0) }
}
