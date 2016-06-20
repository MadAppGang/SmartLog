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
            StorageManager() as StorageService
        }
        
        resolver.register() {
            DataToSendGenerationManager() as DataToSendGenerationService
        }
        
        let storageService = try! resolve() as StorageService
        let loggingService = try! resolve() as LoggingService
        resolver.register(.Singleton) {
            PebbleManager(storageService: storageService, loggingService: loggingService) as WearableService
        }
    }

    static func resolve<T>() throws -> T {
        return try resolver.resolve() as T
    }
}