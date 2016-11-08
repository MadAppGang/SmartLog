//
//  PolarManager.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 11/7/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import Foundation
import CoreBluetooth

final class PolarManager: NSObject {
    
    fileprivate enum ServiceUUID {
        static let heartRate = CBUUID(string: "180D")
        static let battery = CBUUID(string: "180F")
        
        static var all: [CBUUID] {
            return [ServiceUUID.heartRate, ServiceUUID.battery]
        }
    }
    
    fileprivate enum CharacteristicUUID {
        static let heartRateMeasurement = CBUUID(string: "2A37")
        static let batteryLevel = CBUUID(string: "2A19")
    }
    
    fileprivate let loggingService: LoggingService?
    
    fileprivate var centralManager: CBCentralManager!
    fileprivate var peripheral: CBPeripheral?
    
    init(loggingService: LoggingService? = nil) {
        self.loggingService = loggingService
        
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: .global(qos: .utility))
    }
}

extension PolarManager: WearableService {
    
    var deviceAvailable: Bool {
        return peripheral?.state == .connected
    }
}

extension PolarManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if case .poweredOn = central.state {
            centralManager.scanForPeripherals(withServices: ServiceUUID.all, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name, name.lowercased().contains("polar") else { return }
        
        central.connect(peripheral, options: nil)
        self.peripheral = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let name = peripheral.name {
            loggingService?.log("Device connected: \(name)")
        }
        
        central.stopScan()
        
        peripheral.delegate = self
        peripheral.discoverServices(ServiceUUID.all)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            loggingService?.log("Device connection failure: \(name)\n\(error)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            loggingService?.log("Device disconnected: \(name)")
        }
        
        self.peripheral = nil
        centralManager.scanForPeripherals(withServices: ServiceUUID.all, options: nil)
    }
}

extension PolarManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            let characteristics: [CBUUID]
            
            switch service.uuid {
            case ServiceUUID.heartRate:
                characteristics = [CharacteristicUUID.heartRateMeasurement]
            case ServiceUUID.battery:
                characteristics = [CharacteristicUUID.batteryLevel]
            default:
                continue
            }
            
            peripheral.discoverCharacteristics(characteristics, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            switch (service.uuid, characteristic.uuid) {
            case (ServiceUUID.battery, CharacteristicUUID.batteryLevel):
                self.peripheral?.readValue(for: characteristic)
                fallthrough
            case (ServiceUUID.heartRate, CharacteristicUUID.heartRateMeasurement):
                self.peripheral?.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch (characteristic.service.uuid, characteristic.uuid) {
        case (ServiceUUID.heartRate, CharacteristicUUID.heartRateMeasurement):
            loggingService?.log("🤗: \(characteristic)")
        case (ServiceUUID.battery, CharacteristicUUID.batteryLevel):
            loggingService?.log("💀: \(characteristic)")
        default:
            break
        }
    }
}
