//
//  UIViewController+SegueExtensions.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

protocol EnumerableSegueIdentifier {
    associatedtype SegueIdentifier: RawRepresentable
}

extension EnumerableSegueIdentifier where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    /**
     Syntactic sugar for `performSegue(segueIdentifier segueIdentifier:_, sender:_)` where `self` passed as sender
     */
    func performSegue(segueIdentifier: SegueIdentifier) {
        performSegue(segueIdentifier: segueIdentifier, sender: self)
    }
    
    func performSegue(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    func segueIdentifierForSegue(_ segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(segue.identifier).")
        }
        
        return segueIdentifier
    }
}
