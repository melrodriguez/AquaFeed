import SpriteKit

class Niko: Pet {
    enum State {
        case normal
        case wait
    }

    let pearlTime: Float = 40.0
    var state: State = .normal
    var timeTillPearl: Float = 34.0
    var hasPearlBeenCollected: Bool = false
    var showPearl: Bool = false
    var pearl: Money?

    init() {
        super.init(
            texture: PetTextures.nikoTextures.first!,
            scale: 3.0
        )
        
        guard let levelScene = scene as? LevelScene else { return }
        
        pearl = levelScene.spawnManager.spawnPearl(at: self.position)

        enterState(state)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        case .normal:
            startAnimation()
        case .wait:
            startWait()
        }
    }

    private func startAnimation() {
        let calcTime = timeTillPearl / Float(PetTextures.nikoTextures.count)
        let interval = TimeInterval(calcTime)
        
        
        let animation = SKAction.animate(
            with: PetTextures.nikoTextures,
            timePerFrame: interval
        )
        
        run(animation, withKey: "animation")
    }

    private func startWait() {
        texture = PetTextures.nikoTextures.last!
    }

    func update() {
        timeTillPearl -= 1
        timeTillPearl = max(timeTillPearl, 0)

        if state == .normal && timeTillPearl == 0 {
            print("Time till pearl?")
            setState(.wait)
        }

        if state == .wait && hasPearlBeenCollected {
            timeTillPearl = pearlTime
            setState(.normal)
        }
    }
}
