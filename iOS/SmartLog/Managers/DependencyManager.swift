//
//  DependencyManager.swift
//  SmartLog
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
        
        dependencyContainer.register(.eagerSingleton) { () throws -> PolarManager in
            let loggingService = try! self.resolve() as LoggingService
            
            return PolarManager(loggingService: loggingService)
        }
        
        dependencyContainer.register(.eagerSingleton, tag: WearableImplementation.polar) {
            try! self.resolve() as PolarManager as WearableService
        }
        
        dependencyContainer.register(.eagerSingleton) {
            try! self.resolve() as PolarManager as HRMonitor
        }
        
        let storageService = try! resolve() as StorageService
        
        storageService.configure(
            progressHandler: { progress in
                progressHandler(progress)
            },
            completion: { result in
                switch result {
                case .successful:
                    
                    self.dependencyContainer.register(.eagerSingleton, tag: WearableImplementation.pebble) { () throws -> WearableService in
                        let pebbleDataSaver = PebbleDataSaver(storageService: storageService)
                        let loggingService = try! self.resolve() as LoggingService
                        
                        return PebbleManager(pebbleDataSaver: pebbleDataSaver, loggingService: loggingService)
                    }
                    
                    self.dependencyContainer.register(.eagerSingleton, tag: WearableImplementation.watch) { () throws -> WearableService in
                        let watchDataSaver = WatchDataSaver(storageService: storageService)
                        let loggingService = try! self.resolve() as LoggingService

                        let watchManager = WatchManager(watchDataSaver: watchDataSaver, loggingService: loggingService)
                        let hrMonitor = try! self.resolve() as HRMonitor
                        hrMonitor.add(observer: watchManager)
                        
                        return watchManager
                    }
                    
                    self.dependencyContainer.register(.eagerSingleton) { () throws -> SessionsService in
                        let hrMonitor = try! self.resolve() as HRMonitor
                        
                        return SessionsManager(storageService: storageService, hrMonitor: hrMonitor)
                    }
                    
                    try! self.dependencyContainer.bootstrap()
                    
                    completion(.successful)
                case .failed(let error):
                    completion(.failed(error: error))
                }
            }
        )
    }
    
    func resolve<T>(tag: String? = nil) throws -> T {
        return try dependencyContainer.resolve(tag: tag) as T
    }
}
