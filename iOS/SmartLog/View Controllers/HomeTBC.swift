//
//  HomeTBC.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/4/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit

final class HomeTBC: UITabBarController {

    var dependencyManager: DependencyManager!
    
    private let sessionsTabIndex = 0
    private let recordTabIndex = 1
    private let outputTabIndex = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabsContent()
    }
    
    private func configureTabsContent() {
        guard let viewControllers = viewControllers else { return }

        if let sessionsNC = viewControllers[sessionsTabIndex] as? UINavigationController, let sessionsVC = sessionsNC.viewControllers.first as? SessionsVC {
            sessionsVC.dependencyManager = dependencyManager
            sessionsVC.storageService = try! dependencyManager.resolve() as StorageService
        }
        
        if let outputNC = viewControllers[outputTabIndex] as? UINavigationController, let outputVC = outputNC.viewControllers.first as? OutputVC {
            outputVC.loggingService = try! dependencyManager.resolve() as LoggingService
        }
    }

}
