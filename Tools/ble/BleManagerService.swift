import CoreBluetooth

typealias DeviceAddress = String
let activeDevice = PeripheralDevice()

class BleManagerService : NSObject, CBCentralManagerDelegate {
  static let shared = BleManagerService()

  private var isScanning = false
  private var cbCentralManager: CBCentralManager!
  private let centralQueue = DispatchQueue(label: "com.acer.ios_")
  private var _discoverPeriphals: [DeviceAddress: CBPeripheral] = [:]
  private var _callback: BleStatusCallback!

  //init
  private override init() {}

  var isBTEnable: Bool {
    guard let central = cbCentralManager else {
      Log.w("Bluetooth is currently unavailable to use.")
      return false
    }

    if #available(iOS 10.0, *) {
      switch central.state{
      case CBManagerState.poweredOn:
        Log.i("Bluetooth is currently powered on and available to use.")
        return true
      default:break
      }
    } else {
      // Fallback on earlier versions
      switch central.state.rawValue {
      case 5:
        Log.i("Bluetooth is currently powered on and available to use.")
        return true
      default:break
      }
    }

    Log.w("Bluetooth is currently unavailable to use.")
    return false
  }

  func getConnectionStatus() {
    let st = activeDevice.peripheral?.state ?? .disconnected
    switch st {
    case .connected:
      _callback.onConnectionStatusUpdated(st)
    default:
      _callback.onConnectionStatusUpdated(.disconnected)
    }
  }

  private func getSelectCBPeripheral(_ uuidString: String) -> CBPeripheral? {

    if let cbPeripheral = _discoverPeriphals[uuidString] {
      return cbPeripheral
    }

    guard let cbPeripheral = retrieveSpecifyPeripheral(UUID(uuidString: uuidString)) else {
      Log.i("retrieve device uuid not found : \(uuidString)")
      return nil
    }

    return cbPeripheral
  }

  func startCentralManager(shouldSet callback: BleStatusCallback) {
    guard cbCentralManager == nil else {
      return
    }

    Log.i("--- startCentralManager ---")
    self._callback = callback
    activeDevice.setCallback(callback: callback)

    let options: [String : Any] = [CBCentralManagerOptionRestoreIdentifierKey:"centralManagerIdentifier",
                                   CBCentralManagerOptionShowPowerAlertKey:NSNumber(value: true)]

    cbCentralManager = CBCentralManager(delegate: self,
                                        queue: centralQueue,
                                        options:options)
    recovery()

  }

  func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {

    if let services = dict[CBCentralManagerRestoredStateScanServicesKey] as! [CBUUID]! {
      for service in services {
        Log.i("$$ willRestoreState#CBCentralManagerRestoredStateScanServicesKey : \(service)")
      }
    }

    if let cbps:[CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]! {
      for cbp in cbps {
        Log.i("$$ willRestoreState#CBCentralManagerRestoredStatePeripheralsKey : \(cbp)")
//        if DataController.shared.deviceState.getCurrentUUID() == cbp.identifier.uuidString {
//          activeDevice.peripheral = cbp
//        }
      }
    }

    if let any = dict[CBCentralManagerRestoredStateScanOptionsKey] as! [String: Any]! {
      for (k,v) in any {
        Log.i("$$ willRestoreState++CentralManager#CBCentralManagerRestoredStateScanOptionsKey : \(k) , \(v)")

      }
    }

  }

  //MARK: step1 --> after init CBCentralManager , ble state changed callback
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    Log.d("$$ central manager did update state :\(central.state.rawValue)")
    _callback.onBTStateChanged(isBTEnable ? 1 : 0)
    _ = recovery()
  }

  //MARK: step2 --> scan peropheral
  func scanPeripheral(_ duration: Int) {
    Log.d("scanPeripheral , duration = \(duration)")

    if isScanning {
      Log.w("already scaning...")
    }


     let _ = TimerHandler().delay(duration) {
      _ = self.stopScanPeripheral()
    }


    self.cbCentralManager.scanForPeripherals(withServices: nil, options: nil)
    isScanning = true
  }

    func stopScanPeripheral() {
        if self.isScanning {
            self.cbCentralManager.stopScan()
            self.isScanning = false
            Log.i("stop scan")
            self._callback.onStopScan()
            return
        }
    }

  //MARK: step3 --> discover peripheral
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

    let ad_connectable = advertisementData[CBAdvertisementDataIsConnectable]! as AnyObject

    let connectable = Int(ad_connectable.description!)! == 1

    if connectable {
      _discoverPeriphals.updateValue(peripheral, forKey: peripheral.identifier.uuidString)
      _callback.onPeripheralsFound(peripheral, RSSI.intValue)
    }

  }

  //MARk: step4 --> connect prtipheral
    func connectPeripheral(_ uuid: String) -> Bool {

    Log.i("******* [check bt available] *******")
    guard isBTEnable else {
      Log.i("bt disable")
      return false
    }

    guard let cbPeripheral = getSelectCBPeripheral(uuid) else {
      Log.w("can not find peripheral")
      return false
    }

    switch cbPeripheral.state {
    case .connected:
      if let _ = activeDevice.peripheral {
//        if _pairDevice.connectState == ConnectionState.ServicesDiscoverd {
//          Log.i("services discovered already")
//          return false
//        }
        Log.i("retry discover service")
        activeDevice.discoverService(nil)
      }
      Log.i("cbPeripheral.state : connected, \(cbPeripheral)")
      return false
    case .connecting:
      Log.i("cbPeripheral.state : connecting : connecting, \(cbPeripheral)")
      return false
    default:
      activeDevice.peripheral = cbPeripheral
      break
    }

    let options = [CBCentralManagerOptionShowPowerAlertKey : true,
                   CBConnectPeripheralOptionNotifyOnDisconnectionKey : true,
                   CBConnectPeripheralOptionNotifyOnNotificationKey : true]

    self.cbCentralManager.connect(cbPeripheral, options: options)
    Log.i("## to connectPeripheral , \(cbPeripheral)!!")

    return true
  }

  //MARk: step5 --> prtipheral connected callback
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

    Log.i("$$ connect success , current CBperipheral : \(peripheral)")
    if isScanning {
        stopScanPeripheral()
    }

    activeDevice.peripheral = peripheral
    activeDevice.discoverService(nil)
    _discoverPeriphals.removeAll()
  }

  //connect error
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    Log.w("$$ connect fail : \(String(describing: error))")
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    Log.i("$$ did disconnect peripheral :\(peripheral), error: \(String(describing: error))")

    _callback.onConnectionStatusUpdated(.disconnected)
    recovery()
  }

  @discardableResult
  func disconnectFromPeripheral() -> Bool {

    guard let peripheral = activeDevice.peripheral else {
      Log.i("device already clear up")
      return false
    }

    switch peripheral.state {
    case .connected, .connecting:
      Log.i("disconnect from peripheral : \(peripheral)")
      self.cbCentralManager.cancelPeripheralConnection(peripheral)
    default:
      Log.i("device already disconnected")
      return false
    }

    return true
  }

  @discardableResult
  private func recovery() -> Bool {
    Log.i("--- BT recovery ---")

    ///TODO: 1. check is paired , go next step
    guard false else {
      return false
    }

    return connectPeripheral(activeDevice.uuid)
  }

  private func retrieveSpecifyPeripheral(_ identifier: UUID?) -> CBPeripheral? {
    guard let uuid = identifier else {
      return nil
    }

    let pList = cbCentralManager.retrievePeripherals(withIdentifiers: [uuid])
    Log.i("retrieve peripheral : \(pList)")
    return pList.first
  }

}

protocol BleStatusCallback {
    func onBTStateChanged(_ status: Int)
    func onConnectionStatusUpdated(_ status: CBPeripheralState)
    func onPeripheralsFound(_ cbPeripheral: CBPeripheral, _ rssi: Int)
    func onStopScan()
}
