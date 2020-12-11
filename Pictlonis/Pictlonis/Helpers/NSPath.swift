//
//  NSPath.swift
//  Pictlonis
//
//  Created by Manuel Teissier on 02/10/2020.
//

import UIKit

//MARK: NSPoint Class
class FBPoint: NSObject {
    var x: CGFloat?
    var y: CGFloat?

    init(point: CGPoint) {
        x = point.x
        y = point.y
        print("NSPath -> New point created")
    }
}

//MARK: NSPath Class
class FBPath: NSObject {
    var points: Array<FBPoint>
    var color: UIColor
    
    init(point: CGPoint,color: UIColor) {
        self.color = color
        self.points = Array<FBPoint>()
        let newPoint = FBPoint(point: point)
        points.append(newPoint)
        print("NSPATH -> Starting in path")
        super.init()
    }
    
    func addPoint(point: CGPoint) {
        let newPoint = FBPoint(point: point)
        points.append(newPoint)
        print("NSPATH -> Appending new point")
    }
    
    func serialize() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        let cGColor = color.cgColor
        dictionary["color"] = CIColor(cgColor: cGColor).stringRepresentation
        let pointsInPath = NSMutableArray()
        for point in points {
            let pointDictionary = NSMutableDictionary()
            pointDictionary["x"] = Int(point.x!) as NSNumber
            pointDictionary["y"] = Int(point.y!) as NSNumber
            pointsInPath.add(pointDictionary)
        }
        dictionary["points"] = pointsInPath
        print(dictionary)
        return dictionary
    }
    
    
    /*func convertToDictionary() -> [String: Any] {
        let pointsInPath = NSMutableArray()
        for point in points {
            //let pointDictionary = NSMutableDictionary()
            let pointDictionary: [String: Any] = ["x": Int(point.x!), "y": Int(point.y!)]
            //let pointDictionary["y"] = Int(point.y!) as NSNumber
            //pointsInPath.add(pointDictionary)
            pointsInPath.add(pointDictionary)
        }
        let dic: [String: Any] = ["color": 1, "points": pointsInPath]
        print("LA PUTAIN DE TA MERE \(dic)")
        return dic
    }*/
}
