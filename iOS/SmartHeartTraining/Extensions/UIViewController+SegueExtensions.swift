//
//  UIViewController+SegueExtensions.swift
//  SmartLog
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
    func performSegue(_ segueIdentifier: SegueIdentifier) {
        performSegue(segueIdentifier, sender: self)
    }
    
    func performSegue(_ segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    func identifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier \(segue.identifier).")
        }
        
        return segueIdentifier
    }
}
