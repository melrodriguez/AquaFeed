import SpriteKit

class Niko: Pet {
    enum State {
        case normal
        case waiting
    }

    let pearlTime: Int = 40
    var state: State = .normal
    var timeTillPearl: Int = 34
    var hasPearlBeenCollected: Bool = false

    init() {
        super.init(
            // Add Niko's texture
            texture: PetType.itchy.moveTextures.first!,
            scale: 1.0
        )

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
        case normal:
            startAnimation()
        case waiting:
            startWait()
        }
    }

    private func startAnimation() {
        // start animation
        print("start animation")
    }

    private func startWait() {
        // Leave mouth open
        print("start wait")
    }

    func update() {
        timeTillPearl -= 1
        timeTillPearl = max(timeTillPearl, 0)

        if state == .normal && timeTillPearl == 0 {
            setState(.wait)
        }

        if state == .wait && hasPearlBeenCollected {
            timeTillPearl = pearlTime
            setState(.normal)
        }
    }
}