//
//  Pets.swift
//  AquaFeed
//
//  Created by Jacob Dains on 7/21/26.
//

import SpriteKit


class Pets: SKSpriteNode {
    var moveTextures: [SKTexture]?
    var turnTextures: [SKTexture]?
    
    init(
        moveTextures: [SKTexture]? = nil,
        turnTextures: [SKTexture]? = nil,
        initialTexture: SKTexture,
        scale: CGFloat
    ) {
        if moveTextures != nil {
            self.moveTextures = moveTextures
        }
        
        if turnTextures != nil {
            self.turnTextures = turnTextures
        }
        
        super.init(
            texture: initialTexture,
            color: .clear,
            size: CGSize(
                width: initialTexture.size().width * scale,
                height: initialTexture.size().height * scale
            )
        )
        
        setScale(scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
