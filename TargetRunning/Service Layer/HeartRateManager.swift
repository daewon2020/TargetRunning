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
            print(characteristic)
        }
    }
}
