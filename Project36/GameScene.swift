//
//  GameScene.swift
//  Project36
//
//  Created by Jonathan Deguzman on 12/6/16.
//  Copyright © 2016 Jonathan Deguzman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        createPlayer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    /// createPlayer() creates the player (a.k.a. the plane) animation
    /// - Returns: nil
    /// - Parameters: none
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        // Position the player most of the way to the top of the screen and most of the way to the left.
        player.position = CGPoint(x: frame.width / 10, y: frame.height * 0.75)
        
        addChild(player)
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        // To get the propeller animation, pass in an array of textures to the animate(with:) method and cycle through each from as fast as possible.
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
    }
}
