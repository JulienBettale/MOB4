//
//  DrawingViewController.swift
//  Pictlonis
//
//  Created by Manuel Teissier on 13/10/2020.
//

import UIKit
import NKOColorPickerView

class DrawingViewController: UIViewController {

    var colorPickerView = NKOColorPickerView()
    var currentColor = String()
    @IBOutlet weak var DrawingView: DrawingView!
    let firebase = SIFirebase.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //firebase.testUnit(text: "TEST ViewController")
    }

    @IBOutlet weak var colorButtonOutlet: UIButton!
    @IBAction func colorButtonAction(_ sender: Any) {
        if (colorButtonOutlet.titleLabel!.text == "Color") {
            let frame = DrawingView.frame
            colorPickerView = NKOColorPickerView(frame: frame, color: UIColor.white) { (color: UIColor!) -> Void in
                let cGColor = color.cgColor
                self.currentColor = CIColor(cgColor: cGColor).stringRepresentation
            }
            view.addSubview(colorPickerView)
            colorButtonOutlet.setTitle("Dismiss", for: .normal)
        } else {
            colorPickerView.removeFromSuperview()
            colorButtonOutlet.setTitle("Color", for: .normal)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: firebase.newColorCallback), object: nil, userInfo: ["newColor": self.currentColor])

            print(self.currentColor)

        }
    }
    
    @IBAction func clearButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: firebase.cleanCanvasCallback), object: nil)
    }
    
}
