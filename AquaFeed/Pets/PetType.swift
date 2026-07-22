import SpriteKit

enum PetType {
    case stinky
    
    var moveTextures: [SKTexture] {
        switch self {
        case .stinky:
            return PetTextures.stinkyMove
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .stinky:
            return 2.5
        }
    }
}
