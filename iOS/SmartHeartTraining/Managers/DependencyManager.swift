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

    func setup(progressHandler: @escaping (_ progress: Float) -> (), completion: @escaping (_ result: SetupCompletion) -> ()) {

        dependencyContainer.register {
            DataToSendGenerationManager() as DataToSendGenerationService
        }
        
        let loggingManager = LoggingManager()
        dependencyContainer.register(.eagerSingleton) {
            loggingManager as LoggingService
        }
        
        let storageManager = StorageManager(purpose: .using)
        dependencyContainer.register(.eagerSingleton) {
            storageManager as StorageService
        }
        
        storageManager.configure(
            progressHandler: { progress in
                progressHandler(progress)
            },
            completion: { result in
                switch result {
                case .successful:
                    
                    let pebbleDataSaver = PebbleDataSaver(storageService: storageManager)
                    self.dependencyContainer.register(.eagerSingleton) {
                        PebbleManager(pebbleDataSaver: pebbleDataSaver, loggingService: loggingManager) as WearableService
                    }
                    
                    let _ = try! self.dependencyContainer.bootstrap()
                    
                    completion(.successful)
                case .failed(let error):
                    completion(.failed(error: error))
                }
            }
        )
    }
    
    func resolve<T>() throws -> T! {
        return try dependencyContainer.resolve() as T
    }
}
