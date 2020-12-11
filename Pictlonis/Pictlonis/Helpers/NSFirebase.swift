//
//  NSFirebase.swift
//  Pictlonis
//
//  Created by Manuel Teissier on 05/10/2020.
//

import UIKit
import Firebase

class SIFirebase {
    let firebaseCallback = "firebaseCallback"
    let cleanCanvasCallback = "cleanCanvasCallback"
    let newColorCallback = "newColorCallback"
    static let sharedInstance = SIFirebase()
    var firebaseHandler = DatabaseHandle()
    
    private init() {
        firebaseHandler = ref.observe(.childAdded, with: { (snapshot:DataSnapshot!) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.firebaseCallback), object: nil, userInfo: ["send": snapshot as Any])
        })
    }

    let pathsInLine = NSMutableSet()
    let ref = Database.database().reference()

    
    func testUnit(text: String) {
        ref.setValue(text)
    }
    
    func resetValues() {
        ref.setValue("")
    }
    
    func addPath(path: FBPath) -> String {
        let FBKey = ref.childByAutoId()
        pathsInLine.add(FBKey)
       // print("SENDING ===> \(path)")
        FBKey.setValue(path.serialize()) { (error, ref: DatabaseReference!) -> Void in
            if let error = error {
                print("Error encountered while saving path in Firebase \(error.localizedDescription)")
            } else {
                self.pathsInLine.remove(FBKey)
            }
        }
        return FBKey.key!
    }
}
