import SwiftUI
import SpriteKit

struct LevelSelectionView: View {
    let onLevelSelected: (LevelConfig) -> Void
    
    var body: some View {
        SpriteView(scene: makeScene())
    }
    
    func makeScene() -> LevelSelectionScene {
        let size = UIScreen.main.bounds.size
        let scene = LevelSelectionScene(size: size)
        
        scene.onLevelSelected = { LevelConfig in
            onLevelSelected(LevelConfig)
        }
        
        return scene
    }
}
