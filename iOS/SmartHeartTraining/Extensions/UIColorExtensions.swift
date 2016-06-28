//
//  UIColorExtensions.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/16/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func appTint() -> UIColor {
        return UIColor(red: 0.40, green: 0.80, blue: 1.00, alpha: 1.0)
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        let redLevel = CGFloat((arc4random_uniform(100) + 1)) / 100
        let greenLevel = CGFloat((arc4random_uniform(100) + 1)) / 100
        let blueLevel = CGFloat((arc4random_uniform(100) + 1)) / 100
        
        return UIColor(red: redLevel, green: greenLevel, blue: blueLevel, alpha: 1.0)
    }
}
