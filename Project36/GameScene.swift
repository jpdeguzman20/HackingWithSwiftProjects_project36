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
    
    var scoreLabel: SKLabelNode!
    
    // Property observer to update the score whenever it changes
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        createPlayer()
        createSky()
        createBackground()
        createGround()
        startRocks()
        createScore()
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
    
    /// createSky() creates the sky background of the screen
    /// - Returns: nil
    /// - Parameters: none
    
    func createSky() {
        // Create the top part of the sky that will take up 67% of the screen and use the anchorPoint property to make it measure up from the center top of the screen
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        // Create the bottom part of the sky that will take up 33% of the screen and use anchorPoint to do the same thing as mentioned above.
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height / 2)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    /// createBackground() creates the scrolling mountain background on the screen
    /// - Returns: nil
    /// - Parameters: none
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            
            // Calculate the x position of each mountain. Since the loop goes from 0 to 1, the first time the loop executes, X will be zero. The second time it executes, X will be the width of the texture minus 1. This prevents any gaps.
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 - i), y: 100)
            
            addChild(background)
            
            // Both mountains will move left a distance equal to its width, jump back another distance the size of its width, and repeat the sequence forever. Combined, these steps create an infinite scrolling landscape.
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    /// createGround() creates the scrolling ground background on the screen
    /// - Returns: nil
    /// - Parameters: none
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2.0)
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
    }
    
    /// createRocks() creates the rocks that the player must fly in between to score points
    /// - Returns: nil
    /// - Parameters: none
    
    func createRocks() {
        // Create the top and bottom spikes, while the top spike is an inverted version of the bottom.
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.zRotation = CGFloat.pi
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        // Create a rectangular box such that if the player touches the box, they score a point.
        let rockCollision = SKSpriteNode(color: UIColor.red, size: CGSize(width: 32, height: frame.height))
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        let xPosition = frame.width + topRock.frame.width
        
        let max = Int(frame.height / 3)
        // Generate a random number to determine where the safe spot between the rocks will be.
        let rand = GKRandomDistribution(lowestValue: -100, highestValue: max)
        
        let yPosition = CGFloat(rand.nextInt())
        
        let rockDistance: CGFloat = 70
        
        // Position the rocks at the right edge of the screen and animate them to the left edge.
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        
        let endPosition = frame.width + (topRock.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }
    
    /// startRocks() uses createRocks() to create rocks, wait three seconds, and create rocks again and agian
    /// - Returns: nil
    /// - Parameters: none
    
    func startRocks() {
        let create = SKAction.run { [unowned self] in
                self.createRocks()
        }
        
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    /// createScore() sets up the player's current score close to the top right corner
    /// - Returns: nil
    /// - Parameters: none
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 40)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "SCORE: 0"
        scoreLabel.color = UIColor.black
        
        addChild(scoreLabel)
    }
}
