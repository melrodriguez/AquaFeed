import SwiftUI
import SpriteKit

struct TitleView: View {
    let onStart: () -> Void
    @State private var showUnlockMessage = false
    
    var body: some View {
        ZStack() {
            Image("aquarium")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack() {
                Image("aquafeed")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 900)
                    .offset(y: -100)
                
                Button(action: onStart) {
                    Image("playButton0")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600)
                }
            }
            
            if showUnlockMessage {
                UnlockMessageView {
                    showUnlockMessage = false
                    GameState.shared.unlockedNewMode = true
                    GameState.shared.save()
                }
            }
        }
        .onAppear {
            //GameState.shared.load()
            
            let completedLevels = GameState.shared.levels
                .filter { $0.completed }
            
            if completedLevels.contains(where: {$0.id == 5 && $0.completed }) {
                if !GameState.shared.unlockedNewMode {
                    showUnlockMessage = true
                }
            }
        }
    }
}

//#Preview {
//    TitleView()
//}
