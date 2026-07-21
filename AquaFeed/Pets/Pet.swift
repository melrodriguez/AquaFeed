import SpriteKit

class Pet: SKSpriteNode {
//    var moveTextures: [SKTexture]?
//    var turnTextures: [SKTexture]?
    var enemySpawned: Bool = false

    init(
//        moveTextures: [SKTexture]? = nil,
//        turnTextures: [SKTexture]? = nil,
//        initialTexture: SKTexture,
//        scale: CGFloat
        color: UIColor,
        size: CGSize
    ) {
//        if moveTextures != nil {
//            self.moveTextures = moveTextures
//        }
//
//        if turnTextures != nil {
//            self.turnTextures = turnTextures
//        }
        
        super.init(
            texture: nil,
            color: color,
            size: size
        )
        
//        setScale(scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
