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
    
    func hitAt(point: CGPoint) {
        //figure out where the building was hit - Sprite kit positions from the center and CG from the bottom left
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        
        //create new CG context the size of our current sprite
        let renderer = UIGraphicsImageRenderer(size: size)
        
        //Draw our current building image into the context, full building at first, changing when hit
        let img = renderer.image { (ctx) in
            currentImage.draw(at: CGPoint(x: 0, y: 0))
            
            //create an ellipse at the collision point, centered on the impact point. Coordinates 32 up and to the left of the collision, 64x64 in size.
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            
            //set blend mode to .clear, draw the ellipse
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        //convert the contents of CG context back into a UIImage. Save this to the currentImage property for the next hit.
        texture = SKTexture(image: img)
        currentImage = img
            
        //use configurePhysics so SpriteKit will recalculate the per-pixel physics for our damaged building
        configurePhysics()
    }
    
    //stride() lets you loop from one number to another with a specific interval. Can be to a interval or THROUGH an interval.
}
