import SpriteKit

enum PetType: String, Codable {
    case stinky
    case itchy
    case niko
    case prego
    case zorf
    
    var displayName: String {
        switch self {
        case .stinky:
            return "Stinky the Snail"
        case .itchy:
            return "Itchy the Swordfish"
        case .niko:
            return "Niko the Clam"
        case .prego:
            return "Prego the Momma Fish"
        case .zorf:
            return "Zorf the Sea Horse"
        }
    }
    
    var description: String {
        switch self {
        case .stinky:
            return "Catches falling coins. Very fast!"
        case .itchy:
            return "Helps you defend your tank from aliens."
        case .niko:
            return "Gives you a pearl every so often."
        case .prego:
            return "Births babies guppies."
        case .zorf:
            return "Spits out food pellets. Yummy!"
        }
    }
}

struct PetInfo: Identifiable {
    let type: PetType
    let texture: SKTexture
    var unlocked: Bool
    
    var id: PetType {
        type
    }
}
