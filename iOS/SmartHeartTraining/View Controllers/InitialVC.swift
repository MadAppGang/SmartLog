//
//  InitialVC.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class InitialVC: UIViewController, EnumerableSegueIdentifier {

    enum SegueIdentifier: String {
        case toSessionsNC
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        performSegue(segueIdentifier: .toSessionsNC)
    }
}
