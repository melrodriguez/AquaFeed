import SwiftUI
import SpriteKit

struct GameView: View {
    enum Screen {
        case title
        case levelSelect
        case playing(LevelConfig, UUID)
        case unlockedPet(PetInfo)
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
                screen = .playing(levelConfig, UUID())
            }
        case .playing(let levelConfig, let id):
            LevelView(
                config: levelConfig,
                onComplete: {
                    onComplete(pet: levelConfig.prize)
                },
                onRestart: {
                    screen = .playing(levelConfig, UUID())
                },
                onExit: {
                    screen = .levelSelect
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
