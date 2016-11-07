//
//  HomeTBC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/4/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class HomeTBC: UITabBarController {

    private enum TabIndex {
        static let sessions = 0
        static let record = 1
        static let output = 2
    }
    
    var dependencyManager: DependencyManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabsContent()
    }
    
    private func configureTabsContent() {
        guard let viewControllers = viewControllers else { return }

        if let sessionsNC = viewControllers[TabIndex.sessions] as? UINavigationController, let sessionsVC = sessionsNC.viewControllers.first as? SessionsVC {
            sessionsVC.dependencyManager = dependencyManager
            sessionsVC.storageService = try! dependencyManager.resolve() as StorageService
        }
        
        if let outputNC = viewControllers[TabIndex.output] as? UINavigationController, let outputVC = outputNC.viewControllers.first as? OutputVC {
            outputVC.loggingService = try! dependencyManager.resolve() as LoggingService
        }
    }

}
