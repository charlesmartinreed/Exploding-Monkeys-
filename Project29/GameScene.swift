//
//  GameScene.swift
//  Project29
//
//  Created by Charles Martin Reed on 8/26/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import SpriteKit

//Collision bitmasks
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2 //only collide with bananas, triggering explosion
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //reference to the view controller, enabling direct communication between them
    weak var viewController: GameViewController!
    
    //MARK:- PROPERTIES
    var buildings = [BuildingNode]()
   
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMove(to view: SKView) {
        
        //setting the physics world delegate
        physicsWorld.contactDelegate = self
        
        //give the scene a dark blue color to represent night sky
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        //put the buildings and monkeys on the scree
        createBuildings()
        createPlayers()
        
    }
   
    //MARK:- Player init
    func createPlayers() {
        //create a player sprite and name it player1
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        
        //create a physics body for the player that collides with bananas, set it not to be dynamic
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        //position player at top of the second building in the array
        let player1Building = buildings[1]
        //player1.size.height because SpriteKit measures from the center of the sprite.
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        
        //add player to the scene
        addChild(player1)
        
        //create player 2
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        
        addChild(player2)
    }
    
    //MARK:- Building init
    func createBuildings() {
        //move horizontally across the screen, filling space with buildings of various sizes until hitting far edge of screen. Starting at -15 on left. 2 point gap between buildings.
        
        var currentX: CGFloat = -15
        
        //landscape game so width is 1024, at least
        while currentX < 1024 {
            let size = CGSize(width: RandomInt(min: 2, max: 4) * 40, height: RandomInt(min: 300, max: 600))
            
            //to space the buildings out a bit
            currentX += size.width + 2
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup() //gives name, physics, creates building...
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    //MARK:- Degrees to radians conversion
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180.0
    }
    
    //MARK:- Game logic
    func launch(angle: Int, velocity: Int) {
        //figure out how hard to throw banana. Take velocity param and divide by 10, by default.
        let speed = Double(velocity) / 10
        
        //convert input angle to radians. Assume input is degrees.
        let radians = deg2rad(degrees: angle)
        
        //if banana already exists, remove it and create a new one using circle physics.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        //if player 1 was throwing the banana, position it up and to left and give it some spin.
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        //set this so that the physics sim can properly handle our small, fast object
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            //Animate player 1 throwing arm up and putting it back down
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            //Make the banana move in the correct diretion
            //cosine of our angle in radians = horizontal momentum to apply to banana
            //sine of our angle in radians = vertical momentum to apply to banana
            //multiply that moment by calculated velocity or -calculated velocity for player2 and turn it into a CGVector
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            
            //use applyImpulse on the banana physics body to push it in a given direction
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            //if player 2 was throwing banana, position it up and to the RIGHT, apply an opposite spin and make it move in the correct direction
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
        
        
    }
    
    //MARK:- Contact logic
    func didBegin(_ contact: SKPhysicsContact) {
        //determining whether banana hit building or vice versa
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if let firstNode = firstBody.node {
            if let secondNode = secondBody.node {
                if firstNode.name == "banana" && secondNode.name == "building" {
                    bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player1" {
                    //player 1 loses
                    destroy(player: player1)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player2" {
                    //player 2 loses
                    destroy(player: player2)
                }
            }
        }
        
    }
    
    func bananaHit(building: BuildingNode, atPoint contactPoint: CGPoint) {
        //convert collision contact point into coordinates relative to building node - if building node was at X:200 and collision was at X:250, it would return X:50 because it was 50 points into the building node.
        let buildingLocation = convert(contactPoint, to: building)
        building.hitAt(point: buildingLocation)
        
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        addChild(explosion)
        
        //prevent banana from hitting building twice - this way the didBegin method won't see our banana as a banana since it has no name
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
        
    }
    
    
    //MARK:- End game logic
    func destroy(player: SKSpriteNode) {
        //make explosion
        let explosion = SKEmitterNode(fileNamed: "hitPlayer")!
        explosion.position = player.position
        addChild(explosion)
        
        //remove destroyed player and banana from scene
        player.removeFromParent()
        banana?.removeFromParent()
        
        //reload the level
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [unowned self] in
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    //what happens if the player misses opponent AND building? When the banana
    //reaches a certain point off the screen, remove it and change player
    override func update(_ currentTime: TimeInterval) {
        if banana != nil {
            if banana.position.y < -1000 {
                banana.removeFromParent()
                banana = nil
                
                changePlayer()
            }
        }
    }
    
}
