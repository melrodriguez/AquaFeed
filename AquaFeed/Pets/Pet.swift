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
    
    init(type: PetType) {
        let scale = type.scale
        
        super.init(
            texture: type.moveTextures.first!,
            color: .clear,
            size: CGSize (
                width: type.moveTextures.first!.size().width * scale,
                height: type.moveTextures.first!.size().height * scale
            )
        )
        
//        setScale(scale)
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
