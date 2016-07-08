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
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private let dependencyManager = DependencyManager()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dependencyManager.setup(
            progressHandler: { progress in
                self.progressView.hidden = !(progress > 0)
                self.progressView.setProgress(progress, animated: true)
            },
            completion: { result in
                switch result {
                case .successful:
                    self.performSegue(segueIdentifier: .toSessionsNC)
                case .failed(let error):
                    self.messageLabel.text = "Failed adding sqlite store.\n\(error)"
                }
            }
        )
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .toSessionsNC:
            guard let sessionsNC = segue.destinationViewController as? UINavigationController, sessionVC =             sessionsNC.viewControllers.first as? SessionsVC else { return }
            
            sessionVC.dependencyManager = dependencyManager
            sessionVC.storageService = try! dependencyManager.resolve() as StorageService
            sessionVC.sessionsChangesService = try! dependencyManager.resolve() as SessionsChangesService
        }
    }
    
}
