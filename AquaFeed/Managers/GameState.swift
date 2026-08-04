import SwiftUI
import SpriteKit

class GameState {
    static let shared = GameState()
    
    var levels: [Level] = [
        Level(id: 1, unlocked: true, completed: false),
        Level(id: 2, unlocked: false, completed: false),
        Level(id: 3, unlocked: false, completed: false),
        Level(id: 4, unlocked: false, completed: false),
        Level(id: 5, unlocked: false, completed: false)
    ]
    
    var pets: [PetInfo] = [
        PetInfo(type: PetType.niko, texture: PetTextures.nikoTextures.first!, unlocked: false),
        PetInfo(type: PetType.stinky, texture: PetTextures.stinkyMove.first!, unlocked: false),
        PetInfo(type: PetType.itchy, texture: PetTextures.itchySwim.first!, unlocked: false),
        PetInfo(type: PetType.prego, texture: PetTextures.pregoSwim.first!, unlocked: false),
        PetInfo(type: PetType.zorf, texture: PetTextures.zorfSwim.first!, unlocked: false)
    ]
    
    var hasCompletedTutorial: Bool = false
    var unlockedNewMode: Bool = false
    var hasCompletedTimeTrialOnce: Bool = false
    var timeTrialHighScore: TimeInterval = 0.0
    
    func save() {
        UserDefaults.standard.set(hasCompletedTutorial, forKey: "hasCompletedTutorial")
        UserDefaults.standard.set(unlockedNewMode, forKey: "unlockedNewMode")
        UserDefaults.standard.set(hasCompletedTimeTrialOnce, forKey: "hasCompletedTimeTrialOnce")
        UserDefaults.standard.set(timeTrialHighScore, forKey: "timeTrialHighScore")

        var unlockedLevels: Set<Int> = []
        
        for level in levels {
            if level.unlocked {
                unlockedLevels.insert(level.id)
            }
        }
        
        UserDefaults.standard.set(
            Array(unlockedLevels),
            forKey: "unlockedLevels"
        )
        
        var unlockedPets: Set<PetType> = []
        
        for pet in pets {
            if pet.unlocked {
                unlockedPets.insert(pet.type)
            }
        }
        
        UserDefaults.standard.set(
            unlockedPets.map { $0.rawValue },
            forKey: "unlockedPets"
        )
    }
    
    func load() {
        hasCompletedTutorial = UserDefaults.standard.bool(
            forKey: "hasCompletedTutorial"
        )
        
        unlockedNewMode = UserDefaults.standard.bool(
            forKey: "unlockedNewMode"
        )
        
        hasCompletedTimeTrialOnce = UserDefaults.standard.bool(
            forKey: "hasCompletedTimeTrialOnce"
        )
        
        timeTrialHighScore = UserDefaults.standard.double(
            forKey: "timeTrialHighScore"
        )
        
        if let savedUnlocked = UserDefaults.standard.array(forKey: "unlockedLevels") as? [Int] {
            let unlockedLevels = Set(savedUnlocked)
            for i in levels.indices {
                if unlockedLevels.contains(levels[i].id) {
                    levels[i].unlocked = true
                }
            }
        }
        
        if let savedPetsUnlocked = UserDefaults.standard.array(forKey: "unlockedPets") as? [String] {
            let unlockedPets = Set(savedPetsUnlocked.compactMap { PetType(rawValue: $0) })
            for i in pets.indices {
                if unlockedPets.contains(pets[i].type) {
                    pets[i].unlocked = true
                }
            }
        }
    }
    
    func getPetInfo(for type: PetType) -> PetInfo? {
        return pets.first { $0.type == type }
    }
    
    func setNextLevelUnlocked(currentLevel: Int) {
        if currentLevel == 5 { return }
        
        let nextLevel = currentLevel + 1
        
        if let index = levels.firstIndex(where: { $0.id == nextLevel }) {
            levels[index].unlocked = true
        }
    }
    
    func setLevelAsComplete(currentLevel: Int) {
        if let index = levels.firstIndex(where: { $0.id == currentLevel }) {
            levels[index].completed = true
        }
    }
    
    func unlockPet(for type: PetType) {
        if let index = pets.firstIndex(where: { $0.type == type }) {
            pets[index].unlocked = true
        }
    }
    
    func getLevelInfo(for config: LevelConfig) -> Level? {
        return levels.first { $0.id == config.level }
    }
}
 
