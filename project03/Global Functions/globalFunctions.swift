//
//  globalFunctions.swift
//  project03
//
//  Created by Tennyson Pinheiro on 10/26/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension UIView {
    
    func fadeIn(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    
    func fadeOut(){
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func fadeOutTopMenu(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func fadeInTopMenu(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.98
        }, completion: nil)
    }
    
    func fadeOutBottomMenu(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func fadeInBottomMenu(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.98
        }, completion: nil)
    }
    
    
    func slideOutFromTop(){
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            //get all the coordinates for the object
            //print(self.superview?.convert(self.frame,to: nil))
            //get only the Y
            //print(self.bounds.origin.y)
            self.bounds.origin.y = 78
            
        }, completion: nil)
    }
    
    func slideInFromTop(){
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            //get all the coordinates for the object
            //print(self.superview?.convert(self.frame,to: nil))
            //get only the Y
            //print(self.bounds.origin.y)
            self.bounds.origin.y = 0
            
        }, completion: nil)
    }
    
    func slideOutFromBottom(){
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            //get all the coordinates for the object
            //print(self.superview?.convert(self.frame,to: nil))
            //get only the Y
            //print(self.bounds.origin.y)
            self.bounds.origin.y = self.bounds.origin.y + 300
            
        }, completion: nil)
    }
    
    func slideInFromBottom(){
        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            //get all the coordinates for the object
            //print(self.superview?.convert(self.frame,to: nil))
            //get only the Y
            //print(self.bounds.origin.y)
            self.bounds.origin.y = self.bounds.origin.y + 70.0
            
        }, completion: nil)
    }
    
    func blinkLittleCart() {
                
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 2
        animation.values = [3, -3, 2, -2 ,1, -1, 0]
        layer.add(animation, forKey: "bounce")
        
    }
    
    
    func simonStyleColorAnimation(ColorOn: UIColor, ColorOff: UIColor, DelayToStart: Double){
        
/*
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            
            self.backgroundColor = ColorOff
        }, completion: nil)
        
        UIView.animate(withDuration: 1, delay: DelayToStart, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            
            self.backgroundColor = ColorOn
            self.backgroundColor = ColorOff
        }, completion: nil)
*/

    }
    
    func bounce() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 4
        animation.values = [0.0, 0.0, 0.0, -210.0, -210.0, 0.0 ]
        layer.add(animation, forKey: "bounce")
    }
    
    func animateCellAfterAdd(){

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.8
        animation.values = [10,20.5, 0.0, -4.0, 0.0 ]
        layer.add(animation, forKey: "animateCellAfterAdd")
        
        /*
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.7
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 1
        }, completion: nil)
      */
        
    }
    
    func animateCellAfterRemove(){
        
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.8
        animation.values = [-10,-20.5, 0.0, -2.0, 0.0 ]
        layer.add(animation, forKey: "animateCellAfterAdd")
     /*
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.7
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 1
        }, completion: nil)
        */
    }
}

func fakeWIDgenerator() -> String {
    return ("w" + String(arc4random()))
}

let roseWineColor: UIColor = UIColor(red: 214/255, green: 65/255, blue: 86/255, alpha: 1)
let whiteWineColor: UIColor = UIColor(red: 70/255, green: 190/255, blue: 188/255, alpha: 1)
let redWineColor: UIColor = UIColor(red: 131/255, green: 30/255, blue: 62/255, alpha: 1)
let offGreyColor: UIColor = UIColor(red: 52/255, green: 58/255, blue: 60/255, alpha: 1)
