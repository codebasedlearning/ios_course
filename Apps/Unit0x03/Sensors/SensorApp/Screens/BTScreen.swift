// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CoreBluetooth
import CblUI

struct BTScreen: View {
    @StateObject private var bluetoothManager = BluetoothManager()

    let columns = [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .trailing),
            GridItem(.flexible(), alignment: .leading)
        ]

    var body: some View {
        CblScreen(title: "ThermoBeacon", image: "weatherhut") {
            HStack {
                LazyVGrid(columns: columns, spacing: 5) {
                    Image(systemName: "thermometer.sun").padding(0)
                    Text(String(format: "%.3f", bluetoothManager.temperature))
                    Text("°C")
                    Image(systemName: "humidity")
                    Text(String(format: "%.3f", bluetoothManager.humidity))
                    Text("%")
                }.font(.title2).frame(width: 300).padding(30)
                Spacer()
            }
            HStack {
                Text("Scan active").padding(5)
                Toggle(isOn: $bluetoothManager.isScanActive) { }
                    .disabled(!bluetoothManager.isBTavailable)
                Spacer()
            }
        }
        .onChange(of: bluetoothManager.isScanActive) { oldState, newState in
            if newState { bluetoothManager.startScan() }
            else { bluetoothManager.stopScanning() }
        }
        .onDisappear {
            bluetoothManager.stopScanning()
        }
    }
}

/*
 
 There are Bluetooth devices with services, GATT and more,
 to which you need to connect in order to receive or exchange data.

 The challenges here are the different use cases, such as finding
 the desired device (out of 100 others), reconnecting in the event of
 a disconnection, e.g. if the mobile device or the BT device are separated,
 and so on.
  
 And there are beacons that just send advertising data on a regular basis.
 These can be monitored.
  
 The snippet here is listening to beacons "ORIA Bluetooth Thermometer Hygrometer",
 available online.
  
 The code that belongs to the case of service is commented out, but it serves
 as a guide to what it would look like.
 
 */

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    
    // sometimes we like to see a list of devices, sometimes we need to keep book
    // on found devices...
    // var peripherals: [CBPeripheral] = []
    // var connectedPeripheral: CBPeripheral?
    // var sensorCharacteristic: CBCharacteristic?
    
    @Published var isBTavailable: Bool = false
    @Published var isScanActive: Bool = false
    @Published var temperature: Double = 0.0
    @Published var humidity: Double = 0.0

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBTavailable = central.state == .poweredOn
    }
    
    func startScan() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            // when you are looking for specific services
            // let specificServices = [CBUUID(string: "FFF0")]
            // centralManager.scanForPeripherals(withServices: specificServices, options: nil)
            isScanActive = true
            // kill it after 10s, scanning usually costs energy
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                self?.stopScanning()
            }
        } else {
            // the user needs more info on that, maybe BT could be enabled
            print("Bluetooth is not available.")
        }

    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanActive = false
        print("Scanning stopped")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // found one: peripherals.append(peripheral)
        peripheral.delegate = self
        
// check name if you are looking for a specific device
//        if let name = peripheral.name, name.contains("ThermoBeacon") {
//            print("connect to \(peripheral.description)")
//                    centralManager.stopScan()
//                    centralManager.connect(peripheral, options: nil)
//                }
        
        // here we look for a thermo-beacon
        if let name = peripheral.name, name.contains("ThermoBeacon") {
            if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                parseBeaconData(manufacturerData)
            }
        }
        print("found \(peripheral.name ?? "?")")
    }
    
    // often this is the hard part to figure out what format the data has
    private func parseBeaconData(_ data: Data) {
        let hexString = data.map { String(format: " %02x", $0) }.joined()
        print("beacon raw data: \(hexString)")

        if data.count == 20 {
            // somewhere in the package is the data
            let batteryData = data.subdata(in: 10..<12)
            let temperatureData = data.subdata(in: 12..<14)
            let humidityData = data.subdata(in: 14..<16)
 
            // convert it
            let temperature: Double = Double(temperatureData.withUnsafeBytes { $0.load(as: Int16.self) }) / 16.0
            let humidity: Double = Double(humidityData.withUnsafeBytes { $0.load(as: UInt16.self) }) / 16.0
            print("battery: \(batteryData), temperature: \(temperature), humidity: \(humidity)")
 
            self.temperature = temperature
            self.humidity = humidity
        }
    }

    /*
     
    from here a list of callbacks follow, the label (e.g. didConnect)
    gives you the idea when it is called
     
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripherals.append(peripheral)
        print("didconnect: \(peripheral.description)")
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("-> discover \(service.description) | \(service.uuid)")
            // looking for specific services
            if service.uuid == CBUUID(string: "FFE0") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            // sometimes you look for specific characteristics
            if characteristic.uuid == CBUUID(string: "FFF3") {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: "FFF5") {
                // Assuming writing a specific value to FFF5 triggers data notification
                let commandData = Data([0x01]) // Example command to request data
                peripheral.writeValue(commandData, for: characteristic, type: .withResponse)
            }
     
            // or
            // if characteristic.properties.contains(.read) {
            //  peripheral.readValue(for: characteristic)
            // }
            // if characteristic.properties.contains(.notify) {
            //  peripheral.setNotifyValue(true, for: characteristic)
            // }
        }
    }

    // now you have data...
     
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let sname = characteristic.service?.description ?? "?"
            let name = peripheral.name
            let uuid = characteristic.uuid
            
            let hexString = dataToHexString(data: data)
            print("Received from service:\(sname), name:\(name ?? "?"), char uuid: \(uuid), cnt:(\(data.count) data in hex: \(hexString)")
        }
    }

    func dataToHexString(data: Data) -> String {
        return data.map { String(format: "%02x ", $0) }.joined()
    }
    */
}
