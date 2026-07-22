import SpriteKit

class Pet: SKSpriteNode {
    init(type: PetType) {
        print(PetType.stinky.moveTextures)
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
