import SpriteKit

class Stinky: Pet {
    enum State {
        case wander
        case hiding
        case collectingCoin
    }
    
    var sceneWidth: CGFloat {
        self.scene?.size.width ?? 0
    }
    
    var minX: CGFloat {
        50
    }
    
    var maxX: CGFloat {
        sceneWidth - 50
    }
    
    var targetMoney: Money?
    var state: State = .wander
    var goingLeft: Bool = true
    var yPos: CGFloat = 10
    var normalSpeed: CGFloat = 100
    var fastSpeed: CGFloat = 150
    
    
    override init(
//        moveTextures: [SKTexture]? = nil,
//        turnTextures: [SKTexture]? = nil,
//        initialTexture: SKTexture,
//        scale: CGFloat
        color: UIColor,
        size: CGSize
    ) {
//        if moveTextures != nil {
//            self.moveTextures = moveTextures
//        }
//
//        if turnTextures != nil {
//            self.turnTextures = turnTextures
//        }
        
        super.init(
            color: color,
            size: size
        )
        
//        setScale(scale)
        setState(.wander)
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
        case .wander:
            wander()
        case .hiding:
            hide()
        case .collectingCoin:
            goToTargetCoin()
        }
    }
    
    private func wander() {
        let endPos = getWanderLocation()
        let distance = abs(endPos.x - position.x)
        let duration = distance / normalSpeed
        
        let move = SKAction.move(to: endPos, duration: duration)
        let next = SKAction.run{ [weak self] in
            self?.wander()
        }
        
        run(.sequence([move, next]))
    }
    
    private func getWanderLocation() -> CGPoint {
        let currentXPos = position.x
        var xPos = 0
        
        if currentXPos == minX {
            goingLeft = false
            turn()
        }
        
        if currentXPos == maxX {
            goingLeft = true
            turn()
        }
        
        if goingLeft {
            return CGPoint (x: minX, y: yPos)
        } else {
            return CGPoint(x: maxX, y: yPos)
        }
    }
    
    private func hide() {
        print("Stinky: I am hiding right now")
    }
    
    private func turn() {
        print("Stinky: I turn")
    }
    
    private func updateTargetCoin() {
        if let money = findNearestMoney() {
            targetMoney = money
            setState(.collectingCoin)
        }
    }
    
    private func findNearestMoney() ->  Money? {
        return GameState.shared.moneyList
            .filter { !$0.isCollected }
            .min {
                getDistance(from: position, to: $0.position) <
                getDistance(from: position, to: $1.position)
            }
    }
    
    private func goToTargetCoin() {
        guard let money = targetMoney,
              !money.isCollected else {
            targetMoney = nil
            state = .wander
            setState(.wander)
            return
        }
        
        let targetXPos = targetMoney!.position.x
        let distance = abs(targetXPos - position.x)
        let duration = distance / fastSpeed
        
        
        if goingLeft && (targetXPos > position.x) {
            goingLeft = false
            turn()
        }
        
        if !goingLeft && (position.x > targetXPos) {
            goingLeft = true
            turn()
        }
        
        let target = CGPoint(x: targetXPos, y: yPos)
        run(SKAction.move(to: target, duration: duration))
    }
}
