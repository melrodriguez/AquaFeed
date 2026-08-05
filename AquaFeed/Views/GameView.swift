import SwiftUI
import SpriteKit

struct GameView: View {
    enum Screen {
        case title
        case levelSelect
        case playing(LevelConfig, [PetType], UUID)
        case unlockedPet(PetInfo, LevelConfig)
        case died(LevelConfig, [PetType], Bool)
        case readySetGo(LevelConfig, [PetType], Bool)
        case petSelection(LevelConfig, Bool)
        case timeTrialMode([PetType], UUID)
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
            } onTimeTrialMode: {
                setupTimeTrialMode()
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
                    screen = .petSelection(levelConfig, false)
                },
                onExit: {
                    screen = .title
                },
                onDied: {
                    screen = .died(levelConfig, petsToSpawn, false)
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
        case .died(let levelConfig, let petsToSpawn, let isTimeTrial):
            DiedView (
                onPlayAgain: {
                    if isTimeTrial {
                        replayTimeTrial(petsToSpawn: petsToSpawn)
                    } else {
                        replayLevel(config: levelConfig, petsToSpawn: petsToSpawn)
                    }
                },
                onExit: {
                    screen = .title
                }
            )
        case .readySetGo(let levelConfig, let petsToSpawn, let isTimeTrial):
            if isTimeTrial {
                ReadySetGoView {
                    screen = .timeTrialMode(petsToSpawn, UUID())
                }
            } else {
                ReadySetGoView {
                    screen = .playing(levelConfig, petsToSpawn, UUID())
                }
            }
        case .petSelection(let levelConfig, let isTimeTrial):
            PetSelectionView { selectedPets in
                screen = .readySetGo(levelConfig, selectedPets, isTimeTrial)
            }
        case .timeTrialMode(let petsToSpawn, let id):
            TimeTrialView(
                petsToSpawn: petsToSpawn,
                onTimeTrialComplete: {
                    screen = .levelSelect
                },
                onRestart: {
                    replayTimeTrial(petsToSpawn: petsToSpawn)
                },
                onChangePets: {
                    setupTimeTrialMode()
                },
                onExit: {
                    screen = .title
                },
                onDied: {
                    screen = .died(LevelConfigs.level1, petsToSpawn, true)
                }
            )
            .id(id)
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
            screen = .petSelection(config, false)
        } else {
            for pet in GameState.shared.pets {
                if pet.unlocked {
                    petsToSpawn.append(pet.type)
                }
            }
            
            screen = .readySetGo(config, petsToSpawn, false)
        }
    }
    
    func replayLevel(config: LevelConfig, petsToSpawn: [PetType]) {
        screen = .readySetGo(config, petsToSpawn, false)
    }
    
    func setupTimeTrialMode() {
        screen = .petSelection(LevelConfigs.level1, true)
    }
    
    func replayTimeTrial(petsToSpawn: [PetType]) {
        screen = .readySetGo(LevelConfigs.level1, petsToSpawn, true)
    }
}
