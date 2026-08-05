import SpriteKit

class Zorf: Pet {
    enum State {
        case swim
        case eject
    }
    
    let moveTextures: [SKTexture] = PetTextures.zorfSwim
    let scale: CGFloat = 3.0
    var state: State = .swim
    var normalSpeed: CGFloat = 100
    var goingLeft: Bool = true
    var giveFoodTime: Int = 2
    var foodTimer: Int = 0

    init() {
        super.init(
            texture: moveTextures.first!,
            scale: scale
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
        case .swim:
            animateWander()
            wander()
        case .eject:
            ejectFood()
        }
    }
    
    private func animateWander() {
        let move = SKAction.repeatForever(
            .animate(
                with: moveTextures,
                timePerFrame: 0.12
            )
        )
        
        run(move, withKey: "animation")
    }

    private func wander() {
        let endPos = getWanderLocation()
        let distance = abs(endPos.x - position.x)
        let duration = distance / normalSpeed
        
        let move = SKAction.move(to: endPos, duration: duration)
        
        var actions: [SKAction] = []
        
        if goingLeft && xScale < 0 {
            actions.append(turnAction())
        } else if !goingLeft && xScale > 0 {
            actions.append(turnAction())
        }
        
        actions.append(move)
        
        let next = SKAction.run{ [weak self] in
            self?.wander()
        }
        
        actions.append(next)
        
        run(
            .sequence(actions),
            withKey: "wander"
        )
    }
    
    private func getWanderLocation() -> CGPoint {
        let currentXPos = position.x
        
        if currentXPos <= minX {
            goingLeft = false
        }
        
        if currentXPos >= maxX {
            goingLeft = true
        }
        
        if goingLeft {
            return CGPoint (x: minX, y: 650)
        } else {
            return CGPoint(x: maxX, y: 650)
        }
    }
    
    private func turnAction() -> SKAction {
        let turn = SKAction.animate(
            with: PetTextures.zorfTurn,
            timePerFrame: 0.06
        )
        
        let flip = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.xScale = self.goingLeft
                ? abs(self.xScale)
                : -abs(self.xScale)
        }
        
        return SKAction.sequence([
            turn,
            flip
        ])
    }
    
    private func ejectFood() {
        let spawnFood = SKAction.run { [weak self] in
            guard let self = self else { return }
            guard let levelScene = self.scene as? LevelScene else { return }
            let offset = goingLeft
                ? -self.size.width / 2.0
                : self.size.width / 2.0
            
            let position = CGPoint(
                x: self.position.x + offset,
                y: self.position.y
            )
            
            levelScene.spawnManager.spawnFood(at: position, quality: FoodQuality.level2)
        }
        
        let goBackToWander = SKAction.run { [weak self] in
            self?.setState(.swim)
        }
        
        run(.sequence([
            spawnFood,
            goBackToWander
        ]))
        
        run(SKAction.playSoundFileNamed(
            "eject.mp3",
            waitForCompletion: false
        ))
    }
    
    func update() {
        foodTimer += 1
        foodTimer = min(foodTimer, giveFoodTime)
        
        if foodTimer == giveFoodTime {
            foodTimer = 0
            setState(.eject)
        }
    }
}
