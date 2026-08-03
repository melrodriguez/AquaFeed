import SpriteKit

enum PetType: String, Codable {
    case stinky
    case itchy
    case niko
    
    var displayName: String {
        switch self {
        case .stinky:
            return "Stinky the Snail"
        case .itchy:
            return "Itchy the Swordfish"
        case .niko:
            return "Niko the Clam"

        }
    }
}

struct PetInfo {
    let type: PetType
    let texture: SKTexture
    var unlocked: Bool
}
