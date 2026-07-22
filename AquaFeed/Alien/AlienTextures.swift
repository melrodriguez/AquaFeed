import SpriteKit

enum AlienTextures {
    static let alienAtlas = SKTextureAtlas(named: "Alien")
    
    static let sylvesterSwim = textures(from: alienAtlas, prefix: "sylvester_swim")
    static let sylvesterDead = alienAtlas.textureNamed("sylvester_dead")
    
    static let balrogSwim = textures(from: alienAtlas, prefix: "balrog_swim")
    static let balrogDead = alienAtlas.textureNamed("balrog_dead")
}
