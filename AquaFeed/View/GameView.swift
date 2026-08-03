import SwiftUI
import SpriteKit

struct GameView: View {
    enum Screen {
        case title
        case levelSelect
        case playing(LevelConfig, [PetType], UUID)
        case unlockedPet(PetInfo)
        case died(LevelConfig, [PetType])
        case readySetGo(LevelConfig, [PetType])
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
                playNewLevel(config: levelConfig)
            }
        case .playing(let levelConfig, let petsToSpawn, let id):
            LevelView(
                config: levelConfig,
                petsToSpawn: petsToSpawn,
                onComplete: {
                    onComplete(pet: levelConfig.prize)
                },
                onRestart: {
                    replayLevel(config: levelConfig, petsToSpawn: petsToSpawn)
                },
                onExit: {
                    screen = .levelSelect
                },
                onDied: {
                    screen = .died(levelConfig, petsToSpawn)
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
        case .died(let levelConfig, let petsToSpawn):
            DiedView (
                onPlayAgain: {
                    replayLevel(config: levelConfig, petsToSpawn: petsToSpawn)
                },
                onExit: {
                    screen = .levelSelect
                }
            )
        case .readySetGo(let levelConfig, let petsToSpawn):
            ReadySetGoView {
                screen = .playing(levelConfig, petsToSpawn, UUID())
            }
        }
    }

    func onStart() {
        if GameState.shared.hasCompletedTutorial {
            screen = .levelSelect
        } else {
            screen = .playing(LevelConfigs.level1, [], UUID())
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
    
    func playNewLevel(config: LevelConfig) {
        let unlockedPetCount = GameState.shared.pets.filter { $0.unlocked }.count
        var petsToSpawn: [PetType] = []

        if unlockedPetCount > 3 {
            print("We got to pet selection")
            petsToSpawn.append(PetType.stinky)
            petsToSpawn.append(PetType.itchy)
            petsToSpawn.append(PetType.niko)
            screen = .readySetGo(config, petsToSpawn)
        } else {
            for pet in GameState.shared.pets {
                print("\(pet.type.displayName)")
                if pet.unlocked {
                    petsToSpawn.append(pet.type)
                }
            }
            
            screen = .readySetGo(config, petsToSpawn)
        }
    }
    
    func replayLevel(config: LevelConfig, petsToSpawn: [PetType]) {
        screen = .readySetGo(config, petsToSpawn)
    }
    
}
