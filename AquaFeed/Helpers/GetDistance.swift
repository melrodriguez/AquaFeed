import SpriteKit

func getDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    let dx = to.x - from.x
    let dy = to.y - from.y
    
    return sqrt(dx * dx + dy * dy)
}
