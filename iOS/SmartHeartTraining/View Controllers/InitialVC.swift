//
//  InitialVC.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit
import Dip

final class InitialVC: UIViewController, EnumerableSegueIdentifier {
    
    enum SegueIdentifier: String {
        case toSessionsNC
    }
    
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private var dependencyContainer = DependencyContainer()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let storageManager = StorageManager(purpose: .using,
            progressHandler: { progress in
                self.progressView.hidden = !(progress > 0)
                self.progressView.setProgress(progress, animated: true)
            },
            completion: { result in
                switch result {
                case .successful:
                    
                    let storageService = try! self.dependencyContainer.resolve() as StorageService
                    let pebbleDataSaver = PebbleDataSaver(storageService: storageService)
                    
                    let loggingService = try! self.dependencyContainer.resolve() as LoggingService
                    self.dependencyContainer.register(.EagerSingleton) {
                        PebbleManager(pebbleDataSaver: pebbleDataSaver, loggingService: loggingService) as WearableService
                    }
                    
                    self.performSegue(segueIdentifier: .toSessionsNC)
                case .failed(let error):
                    self.messageLabel.text = "Failed adding sqlite store.\n\(error)"
                }
            }
        )
        
        dependencyContainer.register(.EagerSingleton) {
            storageManager as StorageService
        }
        
        dependencyContainer.register(.EagerSingleton) {
            LoggingManager() as LoggingService
        }
        
        dependencyContainer.register(.Singleton) {
            SessionsChangesMonitor() as SessionsChangesService
        }
        
        dependencyContainer.register {
            DataToSendGenerationManager() as DataToSendGenerationService
        }
        
        let _ = try! dependencyContainer.bootstrap()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .toSessionsNC:
            guard let sessionsNC = segue.destinationViewController as? UINavigationController, sessionVC =             sessionsNC.viewControllers.first as? SessionsVC else { return }
            
            sessionVC.storageService = try! dependencyContainer.resolve() as StorageService
            sessionVC.sessionsChangesService = try! dependencyContainer.resolve() as SessionsChangesService
        }
    }
    
}
