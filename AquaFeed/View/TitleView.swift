import SwiftUI
import SpriteKit

struct TitleView: View {
    let onStart: () -> Void
    
    var body: some View {
        SpriteView(scene: makeScene())
            .ignoresSafeArea()
    }
    
    func makeScene() -> TitleScene {
        let size = UIScreen.main.bounds.size
        let scene = TitleScene(size: size)
        
        scene.onStart = {
            onStart()
        }
        
        return scene
    }
}
