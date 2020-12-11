//
//  DrawingView.swift
//  Pictlonis
//
//  Created by Manuel Teissier on 21/09/2020.
//

import UIKit
import Firebase

class DrawingView: UIView {
    
    var currentTouch:UITouch?
    var currentPath:Array<CGPoint>?
    var currentFBPath: FBPath?
    var currentColor: UIColor?
    var allPaths = Array<FBPath>()
    var allKeys = Array<String>()
    let firebase = SIFirebase.sharedInstance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(getFromFirebase), name: NSNotification.Name(rawValue: firebase.firebaseCallback), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cleanCanvas), name: NSNotification.Name(rawValue: firebase.cleanCanvasCallback), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newColor), name: NSNotification.Name(rawValue: firebase.newColorCallback), object: nil)
    }
    
    @objc func newColor(sender: NSNotification) {
        if let info = sender.userInfo as? Dictionary<String, String> {
            if let newColorString = info["newColor"] {
                let ciColor = CIColor(string: newColorString)
                let uiColor = UIColor(ciColor: ciColor)
                currentColor = uiColor
                print("New color : \(String(describing: newColorString))")
            }
        }
    }
    
    @objc func cleanCanvas(sender: NSNotification) {
        allKeys.removeAll()
        allPaths.removeAll()
        firebase.resetValues()
        setNeedsDisplay()
    }

    @objc func getFromFirebase(sender: NSNotification) {
        if let info = sender.userInfo as? Dictionary<String, DataSnapshot> {
            print(info)
            let data = info["send"]
            if let fbKey = data?.key {
                if !allKeys.contains(fbKey) {
                    if let data = data?.value {
                        let points = (data as AnyObject).value(forKey: "points") as! NSArray
                        let color = (data as AnyObject).value(forKey: "color") as! String
                        let ciColor = CIColor(string: color)
                        let uiColor = UIColor(ciColor: ciColor)
                    //    self.currentColor = uiColor
                        let firstPoint = points.firstObject!
                        let currentPoint = CGPoint(x: (firstPoint as AnyObject).value(forKey: "x") as! Double, y: (firstPoint as AnyObject).value(forKey: "y") as! Double)
                        currentFBPath = FBPath(point: currentPoint, color: uiColor)
                        for point in points {
                            let p = CGPoint(x: (point as AnyObject).value(forKey: "x") as! Double, y: (point as AnyObject).value(forKey: "y") as! Double)
                            currentFBPath?.addPoint(point: p)
                        }
                    }
                    resetPath(sendToFB: false)
                    setNeedsDisplay()
                }
            }
        }
    }
    
    //MARK: Drawing function
    public override func draw(_ rect: CGRect) {
        print("Draw --> init")
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(1.5)
        print("Draw --> set line width")
        context!.beginPath()
        print("Draw --> set color")
        for path in allPaths {
            let pathArray = path.points
            let color = path.color
            context!.setStrokeColor(color.cgColor)
            if let firstPoint = pathArray.first {
                context?.move(to: CGPoint(x: firstPoint.x!, y: firstPoint.y!))
                if (pathArray.count > 1) {
                    for index in 1...pathArray.count - 1 {
                        let currentPoint = pathArray[index]
                        context?.addLine(to: CGPoint(x: currentPoint.x!, y: currentPoint.y!))
                    }
                }
                context?.strokePath()
                print(" --> Line drawn in context")
            }
        }
        if let firstPoint = currentPath?.first {
            context?.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
            if (currentPath!.count > 1) {
                context!.setStrokeColor(self.currentColor?.cgColor ?? UIColor.black.cgColor)
                for index in 1...currentPath!.count - 1 {
                    let currentPoint = currentPath![index]
                    context?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                }
            }
            context?.strokePath()
            print(" --> Line drawn in context")
        }
    }

    //MARK: Touch functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (currentPath == nil) {
            //firebase.testUnit(text: "Test from touch")
            currentTouch = UITouch()
            currentTouch = touches.first
            let currentPoint = currentTouch?.location(in: self)
            if let currentPoint = currentPoint {
                currentPath = Array<CGPoint>()
                currentPath?.append(currentPoint)
                if let currentColor = self.currentColor {
                    currentFBPath = FBPath(point: currentPoint, color: currentColor)
                } else {
                    currentFBPath = FBPath(point: currentPoint, color: UIColor.black)
                }
                print("Starting new path at point \(currentPoint)")
            } else {
                print("Find empty touch")
            }
        }
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        addTouch(touches: touches)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetPath(sendToFB: true)
        print("Touch cancelled")
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        addTouch(touches: touches)
        resetPath(sendToFB: true)
        print("End of path")
        super.touchesEnded(touches, with: event)
    }
    
    func resetPath(sendToFB: Bool) {
        currentTouch = nil
        currentPath = nil
       // currentFBPath?.serialize()
        if let pathToSend = currentFBPath {
            if sendToFB {
                let returnKey = firebase.addPath(path: pathToSend)
                allKeys.append(returnKey)
            }
            allPaths.append(pathToSend)
        }
    }
    
    func addTouch(touches: Set<UITouch>) {
        if (currentPath != nil) {
            for touch in touches {
                if (currentTouch == touch) {
                    let currentPoint = currentTouch?.location(in: self)
                    if let currentPoint = currentPoint {
                        currentPath?.append(currentPoint)
                        currentFBPath?.addPoint(point: currentPoint)
                        print("Appending path with point \(currentPoint)")
                    } else {
                        print("Find an empty touch")
                    }
                }
            }
        }
        setNeedsDisplay()
    }
}
