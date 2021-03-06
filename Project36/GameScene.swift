//
//  GameScene.swift
//  Project36
//
//  Created by Jonathan Deguzman on 12/6/16.
//  Copyright © 2016 Jonathan Deguzman. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    
    var logo: SKSpriteNode!
    
    var gameOver: SKSpriteNode!
    
    var backgroundMusic: SKAudioNode!
    
    var scoreLabel: SKLabelNode!
    
    var bonusLabel: SKLabelNode!
    
    var gameState = GameState.showingLogo
    
    // Property observer to update the score whenever it changes.
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Property observer to update bonus whenever a star is collected.
    var bonus = 0 {
        didSet {
            bonusLabel.text = "Bonus: \(bonus)"
        }
    }
    
    override func didMove(to view: SKView) {
        createLogos()
        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        createBonus()
        
        // Creates the gravity for the player
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        // Create a SKAudioNode object from the music file and add it to the app
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .showingLogo:
            gameState = .playing
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startRocks()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
        case .playing:
            player.physicsBody?.velocity = CGVector(dx: 0, dy: -20)
            // Every time the player taps the screen, push the player upwards.
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        case .dead:
            // Create a fresh GameScene scene and make it transition in with an animation
            let scene = GameScene(fileNamed: "GameScene")!
            let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Make sure that player is not nil, otherwise exit the method
        guard player != nil else { return }
        
        // Take 1/1000 of the player's upward velocity and turn that into rotation spanning 1/10 of a second.
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        
        player.run(rotate)
    }
    
    /// didBegin(_: SKPhysicsContact) handles the possible collisions between the player and surroundings.
    /// - Returns: nil
    /// - Parameters: 
    ///   - contact: the object that has collided with another object
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Check to see if either the plane collided with the rectangle score box or the score box collided with the plane.
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            // Remove the score rectangle from the game so that they can't score double points
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
        
            let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
            run(sound)
        
            score += 1
        
            return
        }
        
        if contact.bodyA.node?.name == "starDetect" || contact.bodyB.node?.name == "starDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
            run(sound)
            
            bonus += 1
            
            return
        }
        
        if contact.bodyA.node == nil || contact.bodyB.node == nil {
            return
        }
        
        // Otherwise, check to see if the player touches the rocks or ground and if so, end the game.
        if contact.bodyA.node == player || contact.bodyB.node == player {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }
            
            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
            run(sound)
            
            // End the game by showing the game over logo and changing the game state to dead
            gameOver.alpha = 1
            gameState = .dead
            backgroundMusic.run(SKAction.stop())
            
            player.removeFromParent()
            speed = 0
        }
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
        
        // Adds physics to the player and tells us when it has collided with something.
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody!.isDynamic = false
        player.physicsBody!.collisionBitMask = 0
        
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
            
            // Sets up the pixel-perfect collision for the ground sprites and then makes them non-dynamic.
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            ground.physicsBody!.isDynamic = false
            
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
        topRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        topRock.physicsBody!.isDynamic = false
        topRock.zRotation = CGFloat.pi
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        bottomRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        bottomRock.physicsBody!.isDynamic = false
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        // Create a rectangular box such that if the player touches the box, they score a point.
        let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height))
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody!.isDynamic = false
        rockCollision.name = "scoreDetect"
        
        let starTexture = SKTexture(imageNamed: "star")
        
        // Create star for bonus scoring.
        let star = SKSpriteNode(texture: starTexture)
        star.physicsBody = SKPhysicsBody(texture: starTexture, size: starTexture.size())
        star.physicsBody!.isDynamic = false
        star.zPosition = -10
        star.size = CGSize(width: 30, height: 30)
        star.name = "starDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        addChild(star)
        
        let xPosition = frame.width + topRock.frame.width
        
        let max = Int(frame.height / 3)
        
        let rockDistance: CGFloat = 60
        
        // Generate a random number to determine where the safe spot between the rocks will be.
        let rand = GKRandomDistribution(lowestValue: -100, highestValue: max)
        let yPosition = CGFloat(rand.nextInt())
        
        let randStar = GKRandomDistribution(lowestValue: Int(frame.minY + 80), highestValue: Int(frame.maxY - 80))
        let yPositionStar = CGFloat(randStar.nextInt())
        
        // Position the rocks at the right edge of the screen and animate them to the left edge.
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        star.position = CGPoint(x: xPosition + frame.midX, y: yPositionStar)
        
        let endPosition = frame.width + (topRock.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
        star.run(moveSequence)
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
        scoreLabel.fontColor = UIColor.black
        
        addChild(scoreLabel)
    }
    
    /// createBonus() sets up the player's current bonus score under the score label
    /// - Returns: nil
    /// - Parameters: none
    
    func createBonus() {
        bonusLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        bonusLabel.fontSize = 24
        
        bonusLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 60)
        bonusLabel.horizontalAlignmentMode = .right
        bonusLabel.text = "BONUS: 0"
        bonusLabel.fontColor = UIColor.black
        
        addChild(bonusLabel)
    }
    
    /// createLogos() creates centralized logos for the intro and game-over page
    /// - Returns: nil
    /// - Parameters: none
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
}
