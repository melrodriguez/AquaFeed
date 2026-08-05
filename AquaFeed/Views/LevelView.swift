import SwiftUI
import SpriteKit

struct LevelView: View {
    @State private var scene: LevelScene
    @State private var isPaused: Bool = false
    let config: LevelConfig
    let onComplete: () -> Void
    let onRestart: () -> Void
    let onChangePets: () -> Void
    let onExit: () -> Void
    let onDied: () -> Void
    
    init(
        config: LevelConfig,
        petsToSpawn: [PetType],
        onComplete: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        onChangePets: @escaping () -> Void,
        onExit: @escaping () -> Void,
        onDied: @escaping () -> Void
    ) {
        self.config = config
        self.onComplete = onComplete
        self.onRestart = onRestart
        self.onChangePets = onChangePets
        self.onExit = onExit
        self.onDied = onDied
        
        let size = UIScreen.main.bounds.size
        let newScene: LevelScene
        
        if GameState.shared.hasCompletedTutorial {
            newScene = LevelScene(size: size, config: config, petsToSpawn: petsToSpawn)
        } else {
            newScene = TutorialScene(size: size, config: config, petsToSpawn: petsToSpawn)
        }
        
        _scene = State(initialValue: newScene)
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.onComplete = {
                        invalidateGameTimer()
                        onComplete()
                    }
                    scene.onPause = {
                        isPaused = true
                    }
                    scene.onDied = {
                        invalidateGameTimer()
                        onDied()
                    }
                    
                    if SoundManager.shared.currentTrack != "level_music" {
                        SoundManager.shared.playMusic(named: "level_music")
                    }
                }
            
            if isPaused {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                PauseMenuView (
                    onResume: {
                        scene.isPaused = false
                        scene.isGamePaused = false
                        isPaused = false
                    },
                    onRestart: {
                        invalidateGameTimer()
                        onRestart()
                    },
                    onChangePets: {
                        onChangePets()
                    },
                    onExit: {
                        invalidateGameTimer()
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
    
    func invalidateGameTimer() {
        scene.gameTimer?.invalidate()
        scene.gameTimer = nil
    }
}
