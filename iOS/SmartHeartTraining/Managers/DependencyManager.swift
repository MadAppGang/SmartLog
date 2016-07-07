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
    
    static private var resolver: DependencyContainer!
    
    static func setupDependencies() {
        resolver = DependencyContainer()
        
        resolver.register(.Singleton) {
            LoggingManager() as LoggingService
        }
        
        resolver.register(.Singleton) {
            StorageManager(purpose: .using) as StorageService
        }
        
        resolver.register(.Singleton) {
            SessionsChangesMonitor() as SessionsChangesService
        }
        
        resolver.register() {
            DataToSendGenerationManager() as DataToSendGenerationService
        }
        
        let pebbleDataSaver = PebbleDataSaver()
        let loggingService = try! resolve() as LoggingService
        resolver.register(.Singleton) {
            PebbleManager(pebbleDataSaver: pebbleDataSaver, loggingService: loggingService) as WearableService
        }
    }

    static func resolve<T>() throws -> T {
        return try resolver.resolve() as T
    }
}