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
    }
    
    private enum CharacteristicUUID {
        
    }
    
    fileprivate let loggingService: LoggingService?
    
    fileprivate var centralManager: CBCentralManager!
    fileprivate var peripheral: CBPeripheral?
    
    init(loggingService: LoggingService? = nil) {
        self.loggingService = loggingService
        
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
}

extension PolarManager: WearableService {
    
    var deviceAvailable: Bool {
        return peripheral?.state == .connected
    }
}

extension PolarManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            loggingService?.log("Bluetooth LE is powered on and ready")

            let servicesUUIDs = [ServiceUUID.heartRate]
            centralManager.scanForPeripherals(withServices: servicesUUIDs, options: nil)
            
        case .poweredOff:
            loggingService?.log("Bluetooth LE is powered off")
        case .unsupported:
            loggingService?.log("Bluetooth LE is unsupported on this platform")
        case .unauthorized:
            loggingService?.log("Bluetooth LE state is unauthorized")
        case .unknown:
            loggingService?.log("Bluetooth LE state is unknown")
        case .resetting:
            loggingService?.log("Bluetooth LE is resseting")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        guard name.lowercased().contains("polar") else { return }

        central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let name = peripheral.name {
            loggingService?.log("Device connected \(name)")
        }
        
        peripheral.delegate = self
        
        self.peripheral = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let name = peripheral.name {
            loggingService?.log("Device disconnected \(name)")
        }
    }
}

extension PolarManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}
