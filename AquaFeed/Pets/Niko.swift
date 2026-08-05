import SpriteKit

class Niko: Pet {
    enum State {
        case none
        case normal
        case wait
    }

    let maxPearlTime: Int = 40
    let showPearlIndex: Int = 3
    var state: State = .none
    var pearlTimer: Int = 0
    var hasPearlBeenCollected: Bool = false
    var showPearl: Bool = false
    var pearl: Money?

    init() {
        super.init(
            texture: PetTextures.nikoTextures.first!,
            scale: 3.0
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignPearl() {
        guard let levelScene = scene as? LevelScene else { return }
        
        pearl = levelScene.spawnManager.spawnPearl(at: position)
    }

    func setState(_ newState: State) {
        guard state != newState else {return}
        
        exitState()
        state = newState
        enterState(state)
    }

    private func exitState() {
        removeAllActions()
    }

    private func enterState(_ state: State) {
        switch state {
        case .none:
            return
        case .normal:
            assignPearl()
            texture = PetTextures.nikoTextures[0]
        case .wait:
            run(SKAction.playSoundFileNamed(
                "niko_open.mp3",
                waitForCompletion: false
            ))
            startWait()
        }
    }

    private func setTextures(index: Int) {
        texture = PetTextures.nikoTextures[index]
        
        if index == showPearlIndex {
            guard let pearl = pearl else { return }
            
            pearl.isHidden = false
        }
    }

    private func startWait() {
        texture = PetTextures.nikoTextures.last!
    }

    func update() {
        pearlTimer += 1
        pearlTimer = min(pearlTimer, maxPearlTime)
        
        
        if state == .normal {
            guard let pearl = pearl else { return }
            
            if pearlTimer == maxPearlTime {
                pearl.physicsBody?.categoryBitMask = PhysicsCategory.money
                setState(.wait)
            }
            
            if pearlTimer % 10 == 0 {
                setTextures(index: (pearlTimer / 10))
            }
        }
        
        if state == .wait {
            guard let pearl = pearl else { return }

            if pearl.parent == nil {
                guard let levelScene = scene as? LevelScene else { return }
                
                self.pearl = levelScene.spawnManager.spawnPearl(at: self.position)
                pearlTimer = 0
                setState(.normal)
            }
        }
    }
}
