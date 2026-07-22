import SpriteKit

enum PetTextures {
    static let petAtlas = SKTextureAtlas(named: "Pet")
    
    static let stinkyMove = textures(from: petAtlas, prefix: "stinky_move")
    static let stinkyHide = textures(from: petAtlas, prefix: "stinky_hide")
}
