import SwiftUI
import SpriteKit

struct LevelView: View {
    @State private var scene: LevelScene
    @State private var isPaused: Bool = false
    let config: LevelConfig
    let onComplete: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void
    
    init(
        config: LevelConfig,
        onComplete: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        onExit: @escaping () -> Void
    ) {
        self.config = config
        self.onComplete = onComplete
        self.onRestart = onRestart
        self.onExit = onExit
        
        let size = UIScreen.main.bounds.size
        if GameState.shared.hasCompletedTutorial {
            let newScene = LevelScene(size: size, config: config)
            newScene.onComplete = {
                onComplete()
            }
            
            _scene = State(initialValue: newScene)
        } else {
            let newScene = TutorialScene(size: size, config: config)
            
            newScene.onComplete = {
                onComplete()
            }

            _scene = State(initialValue: newScene)
        }
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.onPause = {
                        isPaused = true
                    }
                }
            
            if isPaused {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                PauseMenuView (
                    onResume: {
                        scene.isPaused = false
                        isPaused = false
                    },
                    onRestart: {
                        onRestart()
                    },
                    onExit: {
                        onExit()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            scene.scaleMode = .fill
        }
    }
}
