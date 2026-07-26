import SpriteKit

class Pet: SKSpriteNode {
    var sceneWidth: CGFloat {
        self.scene?.size.width ?? 0
    }
    
    var sceneHeight: CGFloat {
        self.scene?.size.height ?? 0
    }
    
    var minX: CGFloat {
        50
    }
    
    var maxX: CGFloat {
        sceneWidth - 50
    }

    init(texture: SKTexture, scale: CGFloat) {
        super.init(
            texture: texture,
            color: .clear,
            size: CGSize {
                width: texture.size().width * scale
                height: texture.size().height * scale
            }
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func alienAppeared() {
        print("AHH ENEMY APPEARED")
    }
    
    func allAliensDisappeared() {
        print("OKAY FIRE")
    }
}
