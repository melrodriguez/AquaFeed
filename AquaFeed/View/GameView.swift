import SwiftUI
import SpriteKit

struct GameView: View {
    enum Screen {
        case title
        case levelSelect
        case playing(LevelConfig, UUID)
        case unlockedPet(PetInfo)
        case died(LevelConfig)
        case readySetGo(LevelConfig)
    }
    
    @State private var screen: Screen = .title
    
    var body: some View {
        switch screen {
        case .title:
            TitleView {
                onStart()
            }
        case .levelSelect:
            LevelSelectionView { levelConfig in
                screen = .readySetGo(levelConfig)
            }
        case .playing(let levelConfig, let id):
            LevelView(
                config: levelConfig,
                onComplete: {
                    onComplete(pet: levelConfig.prize)
                },
                onRestart: {
                    screen = .readySetGo(levelConfig)
                },
                onExit: {
                    screen = .levelSelect
                },
                onDied: {
                    screen = .died(levelConfig)
                }
            )
            .id(id)
        case .unlockedPet(let petInfo):
            UnlockedPetView(
                onContinue: {
                    onContinue()
                },
                petInfo: petInfo
            )
        case .died(let levelConfig):
            DiedView (
                onPlayAgain: {
                    screen = .readySetGo(levelConfig)
                },
                onExit: {
                    screen = .levelSelect
                }
            )
        case .readySetGo(let levelConfig):
            ReadySetGoView {
                screen = .playing(levelConfig, UUID())
            }
        }
    }

    func onStart() {
        if GameState.shared.hasCompletedTutorial {
            screen = .levelSelect
        } else {
            screen = .playing(LevelConfigs.level1, UUID())
        }
    }
    
    func onComplete(pet: PetType) {
        let petInfo = GameState.shared.getPetInfo(for: pet)
        print(petInfo!.unlocked)
        
        if petInfo != nil && !petInfo!.unlocked {
            screen = .unlockedPet(petInfo!)
            return
        }
        
        screen = .levelSelect
    }
    
    func onContinue() {
        screen = .levelSelect
    }
    
}
