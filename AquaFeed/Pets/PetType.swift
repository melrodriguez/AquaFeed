import SpriteKit

enum PetType: String, Codable {
    case stinky
    case itchy
    case niko
}

struct PetInfo {
    let type: PetType
    let texture: SKTexture
    var unlocked: Bool
}
