//
//  BuildingNode.swift
//  Project29
//
//  Created by Charles Martin Reed on 8/26/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
    //MARK:- Properties
    var currentImage: UIImage!
    
    //method 1: setup() - make this thing a building, setting name, texture and physics
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    //method 2: configurePhysics() - use per-pixel physics for CURRENT sprite texture
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    //method 3: drawBuilding() - draw building as CG render, return it as a UIImage
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { (ctx) in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            var color: UIColor
            
            switch GKRandomSource.sharedRandom().nextInt(upperBound: 3) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            //making the windows
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if RandomInt(min: 0, max: 1) == 0 {
                        ctx.cgContext.setFillColor(lightOnColor.cgColor)
                    } else {
                        ctx.cgContext.setFillColor(lightOffColor.cgColor)
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
         
            //step 4
        }
        
        return img
    }
    
    //stride() lets you loop from one number to another with a specific interval. Can be to a interval or THROUGH an interval.
}
