import SpriteKit

enum PetTextures {
    static let petAtlas = SKTextureAtlas(named: "Pet")
    
    static let stinkyMove = textures(from: petAtlas, prefix: "stinky_move")
    static let stinkyHide = textures(from: petAtlas, prefix: "stinky_hide")
    
    static let itchySwim = textures(from: petAtlas, prefix: "itchy_swim")
    static let itchyTurn = textures(from: petAtlas, prefix: "itchy_turn")
    static let itchyCharge = petAtlas.textureNamed("itchy_charge_01")
    static let itchyChargeTurn = textures(from: petAtlas, prefix: "itchy_charge_turn")
}
