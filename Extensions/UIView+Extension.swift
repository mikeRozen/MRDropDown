//
//  UIView+Extension.swift
//  Pods
//
//  Created by Michael Rozenblat on 09/09/2018.
//

import Foundation
import UIKit

extension UIView{
    
    //    func isResizable() -> Bool{
    //        print("check")
    //        return true
    //    }
    
    //public var object: Any?
    
    
    func removeSubviews(){
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
    func roundCorners(){
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.width / 2;
        self.clipsToBounds = true
    }
    
    func roundCorners(_ radius:CGFloat){
        self.layoutIfNeeded()
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
}

