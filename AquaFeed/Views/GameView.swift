import SwiftUI
import SpriteKit

struct GameView: View {
    enum Screen {
        case title
        case levelSelect
        case playing(LevelConfig, [PetType], UUID)
        case unlockedPet(PetInfo, LevelConfig)
        case died(LevelConfig, [PetType])
        case readySetGo(LevelConfig, [PetType])
        case petSelection(LevelConfig)
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
                    onComplete(pet: levelConfig.prize, config: levelConfig)
                },
                onRestart: {
                    replayLevel(config: levelConfig, petsToSpawn: petsToSpawn)
                },
                onChangePets: {
                    screen = .petSelection(levelConfig)
                },
                onExit: {
                    screen = .title
                },
                onDied: {
                    screen = .died(levelConfig, petsToSpawn)
                }
            )
            .id(id)
        case .unlockedPet(let petInfo, let levelConfig):
            UnlockedPetView(
                onContinue: {
                    onContinue(config: levelConfig)
                },
                petInfo: petInfo
            )
        case .died(let levelConfig, let petsToSpawn):
            DiedView (
                onPlayAgain: {
                    replayLevel(config: levelConfig, petsToSpawn: petsToSpawn)
                },
                onExit: {
                    screen = .title
                }
            )
        case .readySetGo(let levelConfig, let petsToSpawn):
            ReadySetGoView {
                screen = .playing(levelConfig, petsToSpawn, UUID())
            }
        case .petSelection(let levelConfig):
            PetSelectionView { selectedPets in
                screen = .readySetGo(levelConfig, selectedPets)
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
    
    func onComplete(pet: PetType, config: LevelConfig) {
        GameState.shared.setNextLevelUnlocked(currentLevel: config.level)
        GameState.shared.setLevelAsComplete(currentLevel: config.level)
        
        let petInfo = GameState.shared.getPetInfo(for: pet)
        
        if petInfo != nil && !petInfo!.unlocked {
            screen = .unlockedPet(petInfo!, config)
            GameState.shared.unlockPet(for: pet)
            GameState.shared.save()

            return
        }
        
        screen = .levelSelect
    }
    
    func onContinue(config: LevelConfig) {
        let nextLevel = config.next
        if nextLevel != nil {
            let levelInfo = GameState.shared.getLevelInfo(for: nextLevel!)
            if levelInfo != nil {
                if !levelInfo!.completed {
                    playNewLevel(config: nextLevel!)
                    return
                }
            }
        }
       
        // add message has not been shown
        if config.level == 5 {
            screen = .title
            return
        }
        
        screen = .levelSelect
    }
    
    func playNewLevel(config: LevelConfig) {
        let unlockedPetCount = GameState.shared.pets.filter { $0.unlocked }.count
        var petsToSpawn: [PetType] = []

        if unlockedPetCount > 3 {
            screen = .petSelection(config)
        } else {
            for pet in GameState.shared.pets {
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
