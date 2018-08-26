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

class GameScene: SKScene {
    
    //MARK:- PROPERTIES
    var buildings = [BuildingNode]()
    
    override func didMove(to view: SKView) {
        
        //give the scene a dark blue color to represent night sky
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        //call createBuildings
        createBuildings()
    }
   
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
}
