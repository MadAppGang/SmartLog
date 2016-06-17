//
//  UIColor+RandomColor.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func randomColor() -> UIColor {
        let redLevel = CGFloat((arc4random_uniform(100) + 1)) / 100
        let greenLevel = CGFloat((arc4random_uniform(100) + 1)) / 100
        let blueLevel = CGFloat((arc4random_uniform(100) + 1)) / 100
        
        return UIColor(red: redLevel, green: greenLevel, blue: blueLevel, alpha: 1.0)
    }
}