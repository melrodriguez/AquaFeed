import SwiftUI
import SpriteKit

struct LevelSelectionView: View {
    let onLevelSelected: (LevelConfig) -> Void
    let onTimeTrialMode: () -> Void

    @State private var showTimeTrialButton = false
    
    var body: some View {
        ZStack() {
            Image("level_selection_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack() {
                Image("select_level_label")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 800)
                    .offset(y: -200)
                
                HStack(spacing: 80) {
                    ForEach(GameState.shared.levels) { level in
                        if level.unlocked {
                            Button {
                                selectLevel(level: level)
                            } label: {
                                ZStack {
                                    Image("level_button")
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130)
                                    
                                    Text("\(level.id)")
                                        .font(.custom("Menlo-Bold", size: 70))
                                        .foregroundStyle(.white)
                                }
                            }
                        } else {
                            Image("locked_level")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130)
                        }
                    }
                }
                
                Button(action: onTimeTrialMode) {
                    Image("time_trial")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 700)
                }
                .offset(y: 100)
                .opacity(showTimeTrialButton ? 1 : 0)
                .disabled(!showTimeTrialButton)
            }
        }
        .onAppear {
            if GameState.shared.unlockedNewMode {
                showTimeTrialButton = true
            }
        }
    }
    
    func selectLevel(level: Level) {
        let config = LevelConfig.getLevel(level.id)
        
        if config != nil {
            onLevelSelected(config!)
        }
    }
}

#Preview {
    LevelSelectionView { config in
        print("Selected config:", config)
    } onTimeTrialMode: {
        print("time trial :)")
    }
}
