import SpriteKit

class Itchy: Pet {
    enum State {
        case swim
        case charge
    }
    
    var state: State = .swim
    var normalSpeed: CGFloat = 100
    var chargeSpeed: CGFloat = 400
    var goingLeft: Bool = true
    var targetAlien: Alien?
    var isTouchingAlien: Bool = false
    var damageCooldown: TimeInterval = 0.5
    var lastDamageTime: TimeInterval = 0
    var chaseAlien: Bool = false
    
    func setState(_ newState: State) {
        guard state != newState else {return}
        
        exitState()
        state = newState
        enterState(state)
    }
    
    override func alienAppeared() {
        setState(.charge)
    }
    
    override func allAliensDisappeared() {
        setState(.swim)
    }
    
    private func exitState() {
        removeAllActions()
        chaseAlien = false
    }
    
    private func enterState(_ state: State) {
        switch state {
        case .swim:
            animateWander()
            wander()
        case .charge:
            setUpAlienTarget()
        }
    }
    
    private func animateWander() {
        let move = SKAction.repeatForever(
            .animate(
                with: PetType.itchy.moveTextures,
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
            return CGPoint (x: minX, y: 500)
        } else {
            return CGPoint(x: maxX, y: 500)
        }
    }
    
    private func turn() {
        removeAction(forKey: "animation")
        
        let turn = SKAction.animate(
            with: PetType.itchy.turnTextures,
            timePerFrame: 0.06
        )
        
        run(turn) { [weak self] in
            guard let self = self else { return }
            
            self.xScale = self.goingLeft ? abs(self.xScale) : -abs(self.xScale)
            self.animateWander()
        }
    }
    
    private func animateCharge() {
        texture = PetTextures.itchyCharge
    }
    
    private func chargeTurn() {
        self.xScale *= -1
        self.animateCharge()
        self.chaseAlien = true
    }

    func frameUpdate() {
        if state == .charge, let alien = targetAlien {
            if alien.parent == nil {
                targetAlien = nil
                setState(.swim)
            }
            
            let dx = alien.position.x - position.x
            let dy = alien.position.y - position.y

            let distance = sqrt(dx * dx + dy * dy)

            if distance > 1 {
                let step = chargeSpeed / 60.0

                position.x += dx / distance * step
                position.y += dy / distance * step
            }
            
            if isTouchingAlien {
                let currentTime = CACurrentMediaTime()

                if currentTime - lastDamageTime >= damageCooldown {
                    alien.decreaseHealth(damage: 20)
                    alien.bump(from: position)

                    lastDamageTime = currentTime

                    if alien.isDead {
                        targetAlien = nil
                        isTouchingAlien = false
                        GameState.shared.removeDeadAlien()
                        setState(.swim)

                        if !GameState.shared.alienList.isEmpty {
                            setState(.charge)
                        }
                    }
                }
            }
        }
    }
    
    func findNearestAlien() -> Alien? {
        return GameState.shared.alienList
            .min {
                getDistance(from: position, to: $0.position) <
                getDistance(from: position, to: $1.position)
            }
    }
    
    func setUpAlienTarget() {
        if let alien = findNearestAlien() {
            
            if alien.position.x > position.x && goingLeft {
                goingLeft = false
                chargeTurn()
            } else if alien.position.x < position.x && !goingLeft {
                goingLeft = true
                chargeTurn()
            }
            
            targetAlien = alien
            chaseAlien = true
        }
    }
}
