import SpriteKit

enum PetType {
    case stinky
    case itchy
    
    var moveTextures: [SKTexture] {
        switch self {
        case .stinky:
            return PetTextures.stinkyMove
        case .itchy:
            return PetTextures.itchySwim
        }
    }
    
    var turnTextures: [SKTexture] {
        switch self {
        case .stinky:
            return []
        case .itchy:
            return PetTextures.itchyTurn
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .stinky:
            return 2.5
        case .itchy:
            return 3.0
        }
    }
}
