import SwiftUI
import SpriteKit

struct GameView: View {
    var scene: SKScene {
//        let scene = TitleScene()
        let size = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        
        let pet = PetInfo(type: PetType.stinky, texture: PetTextures.stinkyMove.first!, unlocked: false)
        
        let scene = UnlockPetScene(size: size, pet: pet)
//        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GameView()
}
