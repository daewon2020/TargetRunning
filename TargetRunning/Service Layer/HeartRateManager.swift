//
//  HeartRateManager.swift
//  TargetRunning
//
//  Created by Константин Андреев on 19.06.2022.
//

import Foundation
import CoreBluetooth

class HeartRateManager: NSObject {
    static let shared = HeartRateManager()
    typealias Listener = (Int?) -> Void
    
    private var listenerBPM: Listener?
    private var centralManager: CBCentralManager!
    private var heartRatePeripheral: CBPeripheral!
    private let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    private let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")

    
    var currentHeartRate: Int? {
        didSet {
            listenerBPM?(currentHeartRate)
        }
    }
    
    private override init() {
        super.init()
        
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    func bindBPM(listener: @escaping Listener) {
        self.listenerBPM = listener
        listener(currentHeartRate)
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}

extension HeartRateManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
                centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
            @unknown default:
                print("central.state is .unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(heartRatePeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
}

extension HeartRateManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == heartRateMeasurementCharacteristicCBUUID {
            currentHeartRate = heartRate(from: characteristic)
        }
    }
}
