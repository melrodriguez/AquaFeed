import SwiftUI
import SpriteKit

struct TimeTrialView: View {
    @State private var timeStartTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isPaused = false
    @State private var currentLevel = 1
    @State private var scene: LevelScene
    @State private var showScoreOverlay = false

    let petsToSpawn: [PetType]
    let onTimeTrialComplete: () -> Void
    let onRestart: () -> Void
    let onChangePets: () -> Void
    let onExit: () -> Void
    let onDied: () -> Void

    init(
        petsToSpawn: [PetType],
        onTimeTrialComplete: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        onChangePets: @escaping () -> Void,
        onExit: @escaping () -> Void,
        onDied: @escaping () -> Void
    ) {
        self.petsToSpawn = petsToSpawn
        self.onTimeTrialComplete = onTimeTrialComplete
        self.onRestart = onRestart
        self.onChangePets = onChangePets
        self.onExit = onExit
        self.onDied = onDied
        
        let size = UIScreen.main.bounds.size
        let newScene: LevelScene
        let config = LevelConfig.getLevel(1)!
        
        newScene = LevelScene(size: size, config: config, petsToSpawn: petsToSpawn)
        _scene = State(initialValue: newScene)
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .id(currentLevel)
                .ignoresSafeArea()
                .onAppear {
                    setupScene()
                }
            
            VStack {
                TimelineView(.periodic(from: .now, by: 0.01)) { _ in
                    Text(formatTime(currentElapsedTime))
                        .font(.custom("Menlo-Bold", size: 50))
                        .foregroundStyle(.white)
                }
            }
            .offset(y: 470)
            .opacity(showScoreOverlay ? 0: 1)

            
            if isPaused {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                PauseMenuView (
                    onResume: {
                        resumeTimer()
                        scene.isPaused = false
                        scene.isGamePaused = false
                        isPaused = false
                    },
                    onRestart: {
                        onRestart()
                    },
                    onChangePets: {
                        onChangePets()
                    },
                    onExit: {
                        onExit()
                    }
                )
            }
            
            if showScoreOverlay {
                ScoreOverlayView(
                    totalTime: elapsedTime,
                    onFinished: {
                        showScoreOverlay = false
                        onTimeTrialComplete()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            scene.scaleMode = .fill
            if timeStartTime == nil {
                startTimer()
            }
        }
    }
    
    func completeLevel() {
        if currentLevel == 5 {
            scene.isPaused = true
            scene.isGamePaused = true
            pauseTimer()
            
            if GameState.shared.hasCompletedTimeTrialOnce {
                if GameState.shared.timeTrialHighScore > elapsedTime {
                    GameState.shared.timeTrialHighScore = elapsedTime
                }
            } else {
                GameState.shared.timeTrialHighScore = elapsedTime
                GameState.shared.hasCompletedTimeTrialOnce = true
            }
            
            showScoreOverlay = true
            return
        }
        
        currentLevel += 1
        
        let size = UIScreen.main.bounds.size
        let newScene: LevelScene
        guard let config = LevelConfig.getLevel(currentLevel) else { return }
        newScene = LevelScene(size: size, config: config, petsToSpawn: petsToSpawn)
        
        scene.gameTimer?.invalidate()
        scene.gameTimer = nil
        
        scene = newScene
        setupScene()
    }
    
    func setupScene() {
        scene.onComplete = {
            completeLevel()
        }
        scene.onPause = {
            pauseTimer()
            isPaused = true
        }
        scene.onDied = {
            onDied()
        }
        
        scene.scaleMode = .fill
    }
    
    func startTimer() {
        timeStartTime = Date()
    }
    
    func resumeTimer() {
        timeStartTime = Date()
    }
    
    func pauseTimer() {
        guard !isPaused, let startTime = timeStartTime else {
            return
        }
        
        elapsedTime += Date().timeIntervalSince(startTime)
    }
    
    
    var currentElapsedTime: TimeInterval {
        guard let startTime = timeStartTime else {
            return elapsedTime
        }
        
        if isPaused { return elapsedTime }
        
        return elapsedTime + Date().timeIntervalSince(startTime)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let hundredths = Int((time * 100).truncatingRemainder(dividingBy: 100))
        
        return String(
            format: "%02d:%02d.%02d",
                    minutes,
                    seconds,
                    hundredths
        )
    }
}
