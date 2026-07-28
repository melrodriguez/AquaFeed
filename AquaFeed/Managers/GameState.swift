import SwiftUI
import SpriteKit

class GameState {
    static let shared = GameState()
    
    var levels: [Level] = [
        Level(id: 1, unlocked: true),
        Level(id: 2, unlocked: false),
        Level(id: 3, unlocked: false),
        Level(id: 4, unlocked: false),
        Level(id: 5, unlocked: false),
    ]
    
    var pets: [PetInfo] = [
        PetInfo(type: PetType.stinky, texture: PetTextures.stinkyMove.first!, unlocked: false),
        PetInfo(type: PetType.itchy, texture: PetTextures.itchySwim.first!, unlocked: false),
        PetInfo(type: PetType.niko, texture: PetTextures.nikoTextures.first!, unlocked: false),
    ]
    
    var hasCompletedTutorial: Bool = false
    
    func save() {
        UserDefaults.standard.set(hasCompletedTutorial, forKey: "hasCompletedTutorial")
        
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
}
