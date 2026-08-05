import SwiftUI
import SpriteKit

struct UnlockedPetView: View {
    let onContinue: () -> Void
    let petInfo: PetInfo
    
    var body: some View {
        SpriteView(scene: makeScene())
            .ignoresSafeArea()
            .onAppear {
                SoundManager.shared.playMusic(named: "achievement_unlocked", loop: false)
            }
    }

    func makeScene() -> UnlockPetScene {
        let size = UIScreen.main.bounds.size
        let scene = UnlockPetScene(size: size, pet: petInfo)
        
        scene.onContinue = {
            onContinue()
        }
        
        return scene
    }
}
