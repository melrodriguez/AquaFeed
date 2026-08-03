import SpriteKit

class Stinky: Pet {
    enum State {
        case wander
        case hiding
        case collectingCoin
    }
    
    var yPos: CGFloat {
        (sceneHeight - (sceneHeight * 0.70)) / 2
    }
    
    let moveTextures: [SKTexture] = PetTextures.stinkyMove
    let hideTextures: [SKTexture] = PetTextures.stinkyHide
    let scale: CGFloat = 2.5
    var targetMoney: Money?
    var state: State = .hiding
    var goingLeft: Bool = true
    var normalSpeed: CGFloat = 100

    init() {
        super.init(
            texture: moveTextures.first!,
            scale: scale
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func alienAppeared() {
        setState(.hiding)
    }
    
    override func allAliensDisappeared() {
        setState(.wander)
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
            animateWander()
            wander()
        case .hiding:
            hide()
        case .collectingCoin:
            animateGoToCoin()
            goToTargetCoin()
        }
    }
    
    private func animateWander() {
        let move = SKAction.repeatForever(
            .animate(
                with: moveTextures,
                timePerFrame: 0.08
            )
        )
        
        run(move, withKey: "animation")
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
        
        if currentXPos <= minX {
            goingLeft = false
            turn()
        }
        
        if currentXPos >= maxX {
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
        let hide = PetTextures.stinkyHide
        
        let animation = SKAction.sequence([
            .setTexture(hide[0]),
            .wait(forDuration: 0.1),
            .setTexture(hide[1])
        ])
        
        run(animation)
    }
    
    private func turn() {
        removeAction(forKey: "animation")
        xScale *= -1
        
        if state == .wander {
            animateWander()
        }
    }
    
    func updateTargetCoin() {
        if targetMoney != nil {
            return
        }
        
        if let money = findNearestMoney() {
            targetMoney = money
            setState(.collectingCoin)
        } else {
            setState(.wander)
        }
    }
    
    private func findNearestMoney() ->  Money? {
        return LevelState.shared.moneyList
            .filter { !$0.isCollected }
            .min {
                getDistance(from: position, to: $0.position) <
                getDistance(from: position, to: $1.position)
            }
    }
    
    private func animateGoToCoin() {
        let move = SKAction.repeatForever(
            .animate(
                with: moveTextures,
                timePerFrame: 0.07
            )
        )
        
        run(move, withKey: "animation")
    }

    private func goToTargetCoin() {
        guard let money = targetMoney,
              !money.isCollected else {
            targetMoney = nil
            setState(.wander)
            return
        }
        
        let targetXPos = targetMoney!.position.x
        let duration = 0.2
        
        if goingLeft && (targetXPos > position.x) {
            goingLeft = false
            turn()
        }
        
        if !goingLeft && (position.x > targetXPos) {
            goingLeft = true
            turn()
        }
        
        let target = CGPoint(x: targetXPos, y: yPos)
        let move = SKAction.move(to: target, duration: duration)
        let removeMovingAnimation = SKAction.run { [weak self] in
            self?.removeAction(forKey: "animation")
        }
        
        let sequence = SKAction.sequence([
            move,
            removeMovingAnimation
        ])
        
        run(sequence)
    }
    
}
