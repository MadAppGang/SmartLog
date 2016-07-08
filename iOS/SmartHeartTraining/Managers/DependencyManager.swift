//
//  DependencyManager.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import Dip

final class DependencyManager {
    
    enum SetupCompletion {
        case successful
        case failed(error: NSError)
    }
    
    private let dependencyContainer = DependencyContainer()

    func setup(progressHandler progressHandler: (progress: Float) -> (), completion: (result: SetupCompletion) -> ()) {

        dependencyContainer.register {
            DataToSendGenerationManager() as DataToSendGenerationService
        }

        dependencyContainer.register(.Singleton) {
            SessionsChangesMonitor() as SessionsChangesService
        }
        
        let loggingManager = LoggingManager()
        dependencyContainer.register(.EagerSingleton) {
            loggingManager as LoggingService
        }
        
        let storageManager = StorageManager(purpose: .using)
        dependencyContainer.register(.EagerSingleton) {
            storageManager as StorageService
        }
        
        storageManager.configure(
            progressHandler: { progress in
                progressHandler(progress: progress)
            },
            completion: { result in
                switch result {
                case .successful:
                    
                    let pebbleDataSaver = PebbleDataSaver(purpose: .using, storageService: storageManager)
                    self.dependencyContainer.register(.EagerSingleton) {
                        PebbleManager(pebbleDataSaver: pebbleDataSaver, loggingService: loggingManager) as WearableService
                    }
                    
                    let _ = try! self.dependencyContainer.bootstrap()
                    
                    completion(result: .successful)
                case .failed(let error):
                    completion(result: .failed(error: error))
                }
            }
        )
    }
    
    func resolve<T>() throws -> T {
        return try dependencyContainer.resolve() as T
    }
}