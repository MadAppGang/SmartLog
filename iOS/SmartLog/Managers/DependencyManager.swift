//
//  DependencyManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/17/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import Dip

protocol DependencyTag: DependencyTagConvertible {
    
}

final class DependencyManager {
    
    enum SetupCompletion {
        case successful
        case failed(error: NSError)
    }
    
    private let dependencyContainer = DependencyContainer()

    func setup(progressHandler: @escaping (_ progress: Float) -> Void, completion: @escaping (_ result: SetupCompletion) -> Void) {

        dependencyContainer.register {
            DataToSendGenerationManager() as DataToSendGenerationService
        }
        
        dependencyContainer.register(.eagerSingleton) {
            LoggingManager() as LoggingService
        }
        
        dependencyContainer.register(.eagerSingleton) {
            StorageManager(for: .using) as StorageService
        }
        
        let storageService = try! resolve() as StorageService
        
        storageService.configure(
            progressHandler: { progress in
                progressHandler(progress)
            },
            completion: { result in
                switch result {
                case .successful:
                    
                    let loggingService = try! self.resolve() as LoggingService
                    
                    let pebbleDataSaver = PebbleDataSaver(storageService: storageService)
                    self.dependencyContainer.register(.eagerSingleton, tag: WearableImplementation.pebble) {
                        PebbleManager(pebbleDataSaver: pebbleDataSaver, loggingService: loggingService) as WearableService
                    }
                    
                    let watchDataSaver = WatchDataSaver(storageService: storageService)
                    self.dependencyContainer.register(.eagerSingleton, tag: WearableImplementation.watch) {
                        WatchManager(watchDataSaver: watchDataSaver, loggingService: loggingService) as WearableService
                    }
                    
                    let polarManager = PolarManager(loggingService: loggingService)
                    self.dependencyContainer.register(.eagerSingleton, tag: WearableImplementation.polar) {
                        polarManager as WearableService
                    }
                    
                    self.dependencyContainer.register(.eagerSingleton) {
                        polarManager as HRMonitor
                    }
                    
                    try! self.dependencyContainer.bootstrap()
                    
                    completion(.successful)
                case .failed(let error):
                    completion(.failed(error: error))
                }
            }
        )
    }
    
    func resolve<T>(tag: DependencyTag? = nil) throws -> T {
        return try dependencyContainer.resolve(tag: tag) as T
    }
}
