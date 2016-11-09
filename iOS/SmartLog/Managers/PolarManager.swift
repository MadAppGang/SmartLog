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
        guard let binaryData = characteristic.value else { return }

        var bytes = [UInt8](repeating: 0, count: binaryData.count)
        binaryData.copyBytes(to: &bytes, count: bytes.count)

        switch (characteristic.service.uuid, characteristic.uuid) {
        case (ServiceUUID.heartRate, CharacteristicUUID.heartRateMeasurement):

            /**
             Property represents a set of bits, which values describe markup for bytes in heart rate data.
             
             Bits grouped like `| 000 | 0 | 0 | 00 | 0 |` where: 3 bits are reserved, 1 bit for RR-Interval, 1 bit for Energy Expended Status, 2 bits for Sensor Contact Status, 1 bit for Heart Rate Value Format
             */
            let flags = bytes[0]
            
            let contactStatusValue = (Int(flags) >> 1) & 0x3 // 0-1 - not supported, 2 - disconnected, 3 - connected
            
            var range: Range<Int>
            
            var heartRateValue: Int
            if flags & 0x1 == 0 {
                range = 1..<(1 + MemoryLayout<UInt8>.size)
                heartRateValue = Int(bytes[1])
            } else {
                range = 1..<(1 + MemoryLayout<UInt16>.size)
                heartRateValue = Int(UnsafePointer(Array(bytes[range])).withMemoryRebound(to: UInt16.self, capacity: 1, { $0.pointee }))
            }
            
            loggingService?.log("❤️: \(heartRateValue) \(contactStatusValue)")
        case (ServiceUUID.battery, CharacteristicUUID.batteryLevel):
            let batteryLevel = Int(bytes[0])
            
            if let name = peripheral.name {
                loggingService?.log("\(name): 🔋 \(batteryLevel)%")
            }
        default:
            break
        }
    }
}
