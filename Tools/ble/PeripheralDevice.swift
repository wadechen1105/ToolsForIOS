import Foundation
import CoreBluetooth

let testQ = DispatchQueue(label: "test__")

class PeripheralDevice : NSObject, CBPeripheralDelegate {

    private var _cbPeripheral: CBPeripheral?
    var peripheral: CBPeripheral? {
        set {
            // Fix bug: cbPeripheral.delegate will point to wrong instance because select peripheral screen refresh too fast
            // Move to Peripheral#diddisconnect
            _cbPeripheral = newValue
            _cbPeripheral!.delegate = self
        }

        get {
            return _cbPeripheral
        }
    }

    private var _callback: BleStatusCallback?

    var name: String {

        get{
            // iOS does not advertise peripheral name in background
            // and even the peripheral is in foreground, the central might still use peripheral's old cached name
            // So only use peripheral's name when explicit name is unavialable
            if _cbPeripheral == nil {
                return "Unknown"
            }

            if let name = _cbPeripheral!.name {
                return name
            } else {
                return "Unknown"
            }
        }
    }

    var advertisements: [String : Any]?

    var uuid: String {
        get {
            return _cbPeripheral?.identifier.uuidString ?? ""
        }
    }

    func setCallback(callback: BleStatusCallback) {
        self._callback = callback
    }

    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        Log.i("## peripheralDidUpdateRSSI \(peripheral) : has error: \(String(describing: error))")
    }

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        Log.i("## peripheralDidUpdateName \(peripheral)")
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        Log.i("## didModifyServices \(peripheral), invalidatedServices: \(invalidatedServices)")
    }

    func discoverService(_ services: [CBUUID]?) {
        _cbPeripheral!.discoverServices(services)
    }

    // ##callback. already discover services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Log.i("$$ didDiscoverServices")
        if (error == nil) {
            if let services = peripheral.services {
                for cbService in services {
                    peripheral.discoverCharacteristics(nil, for: cbService)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        let noError = error == nil
        guard noError else {
            Log.w("discover service and characteristics has error : \(String(describing: error))")
            return
        }

        guard VTDService.isVTD(service) else {
            return
        }

        let vtdSerivce = VTDService(.vtd, service)
        gattList.updateValue(vtdSerivce, forKey: .vtd)
        _callback?.onConnectionStatusUpdated(.connected)
    }

    static var testWriteTime: TimeInterval = 1

    func testWriteData() {
        let vtd = getGattService(.vtd) as! VTDService

        guard let c = vtd.getCharacteristic(VTDService.CHARACTERISTIC_WRITE_NO_RESPONSE) else {
            Log.w("get write data fail")
            return
        }


        Log.i("write -----")
        Thread.sleep(forTimeInterval: PeripheralDevice.testWriteTime)
        let dataBytes: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10,
                                  0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20]

        let d = Data(bytes: UnsafePointer<UInt8>(dataBytes), count: dataBytes.count)
        self.writeCharacteristicWithoutResponse(c, data: d)

    }

    //// get updated value
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Log.i("didUpdateValueFor characteristic : \(characteristic))")

        let gatt = checkWhichByCharacteristic(characteristic)

        guard error == nil && gatt != nil, let data = characteristic.value else {
            Log.w("characteristic nil or error: \(String(describing: error))")
            return
        }

        let bytes = data.toBytes()
        Log.d("bytes: \(bytes)")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Log.d("didDiscoverDescriptorsForCharacteristic, error : \(String(describing: error))")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        Log.d("write characteristic : \(characteristic), has error? \(String(describing: error))")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        Log.i("didUpdateNotificationStateFor : [\(characteristic)]")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        Log.d("connect to peripheral failed , error = \(String(describing: error?.description))")
    }


    /*
     *  @param enabled Whether or not notifications/indications should be enabled.
     */
    private func setNotify(_ characteristic: CBCharacteristic, enabled: Bool) {
        self._cbPeripheral!.setNotifyValue(enabled, for: characteristic)
    }

    func enableNotify(_ characteristic: CBCharacteristic) {
        Log.i("[\(characteristic)] enable notification")
        setNotify(characteristic, enabled: true)
    }

    func disableNotify(_ characteristic: CBCharacteristic) {
        Log.i("[\(characteristic)] disable notification")
        setNotify(characteristic, enabled: false)
    }

    func readCharacterisic(_ characteristic: CBCharacteristic) {
        self._cbPeripheral!.readValue(for: characteristic)
    }

    func writeCharacteristicWithResponse(_ characteristic: CBCharacteristic, data: Data) {
        self._cbPeripheral!.writeValue(data, for: characteristic, type: .withResponse)
    }

    func writeCharacteristicWithoutResponse(_ characteristic: CBCharacteristic, data: Data) {
        self._cbPeripheral!.writeValue(data, for: characteristic, type: .withoutResponse)
    }

}

enum GattType {
    case vtd
}

fileprivate var gattList: [GattType: GATTService] = [:]

/**
 * workaround --> because callback [func peripheral(peripheral: CBPeripheral, didUpdate ..... ] without pass CBService, so we just check by characteristic
 */
fileprivate func checkWhichByCharacteristic(_ characteristics: CBCharacteristic) -> GATTService? {
    for (_, gattService) in gattList {
        let characteristic = gattService.getCharacteristic(characteristics.uuid.uuidString)
        if characteristic != nil {
            return gattService
        }
    }
    return nil
}

internal func getGattService(_ type: GattType) -> GATTService? {
    return gattList[type]
}

class GATTService {
    private var cbService: CBService?
    private var characteristicsDict: [String: CBCharacteristic] = [:]
    var type: GattType!

    init(_ type: GattType, _ cbService: CBService) {
        self.type = type
        self.cbService = cbService
        if let chs = cbService.characteristics {
            for ch in chs {
                self.characteristicsDict.updateValue(ch, forKey: ch.uuid.uuidString)
            }
        }
    }
    
    /**
     * @param cUUID : characteristic uuid
     **/
    func getCharacteristic(_ cUUIDStrig: String) -> CBCharacteristic? {
        return characteristicsDict[cUUIDStrig]
    }
    
}

class VTDService: GATTService {
    static let CHARACTERISTIC_NOTIFY = "49535343-1E4D-4BD9-BA61-23C647249616"
    static let CHARACTERISTIC_WRITE_NO_RESPONSE = "49535343-8841-43F4-A8D4-ECBE34729BB3"
    
    static func isVTD(_ cbService: CBService) -> Bool {
        if let chs = cbService.characteristics {
            for ch in chs {
                let uuid = ch.uuid.uuidString
                if uuid == CHARACTERISTIC_NOTIFY {
                    return true
                } else if uuid == CHARACTERISTIC_WRITE_NO_RESPONSE {
                    return true
                }
            }
        }
        return false
    }
    
}

