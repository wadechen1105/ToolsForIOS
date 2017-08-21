//
//  BleViewController.swift
//  Tools
//
//  Created by Wade.Chen on 2017/7/27.
//  Copyright © 2017年 wade.wade. All rights reserved.
//

import UIKit
import CoreBluetooth

class BleViewController: UITableViewController, BleStatusCallback {
    let cellName = "ble_cell"

    var deivces: [CBPeripheral] = []
    var isW = false

    override var className: String {
        return String(describing: BleViewController.self)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellName)
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        BleManagerService.shared.startCentralManager(shouldSet: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        Thread.sleep(forTimeInterval: TimeInterval(0.5))
        BleManagerService.shared.scanPeripheral(8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onBTStateChanged(_ status: Int) {

    }

    func onConnectionStatusUpdated(_ status: CBPeripheralState) {
        guard let chNotify = getGattService(.vtd)?.getCharacteristic(VTDService.CHARACTERISTIC_NOTIFY) else {
            return
        }

        DispatchQueue.main.async {
            self.deivces.removeAll()
            self.tableView.reloadData()
            if status == .connected {
                activeDevice.enableNotify(chNotify)

                let alertSetTime = UIAlertController(title: "set write time", message: "", preferredStyle: .actionSheet)
                let alert = UIAlertController(title: "Test write vtd", message: "", preferredStyle: .actionSheet)

                let _10ms = UIAlertAction(title: "10 ms" , style: .default) {
                    (action: UIAlertAction) in
                    PeripheralDevice.testWriteTime = 0.01
                    alert.show()
                }

                let _100ms = UIAlertAction(title: "100 ms" , style: .default) {
                    (action: UIAlertAction) in
                    PeripheralDevice.testWriteTime = 0.1
                    alert.show()
                }

                let _1sec = UIAlertAction(title: "1 second" , style: .default) {
                    (action: UIAlertAction) in
                    PeripheralDevice.testWriteTime = 1
                    alert.show()
                }

                alertSetTime.addAction(_10ms)
                alertSetTime.addAction(_100ms)
                alertSetTime.addAction(_1sec)
                alertSetTime.show()


                let write = UIAlertAction(title: "test write data" , style: .default) {
                    (action: UIAlertAction) in
                    Log.d("test write / stop write ...")
                    alert.show()
                    self.isW = !self.isW
                    testQ.async {
                        while self.isW { activeDevice.testWriteData() }
                    }

                }

                let disconnect = UIAlertAction(title: "disconnect" , style: .default) {
                    (action: UIAlertAction) in
                    self.isW = false
                    BleManagerService.shared.disconnectFromPeripheral()
                    alert.dismiss()
                }

                alert.addAction(write)
                alert.addAction(disconnect)
            } else {
                let alert = UIAlertController(title: "disconnected ...", message: "please pull table view to rescan devices", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "ok" , style: .default) {
                    (action: UIAlertAction) in
                    alert.dismiss()
                }

                alert.addAction(dismiss)
                alert.show()
                activeDevice.disableNotify(chNotify)
            }
        }

    }

    @objc
    func handleRefresh() {
        self.deivces.removeAll()
        Thread.sleep(forTimeInterval: TimeInterval(0.5))
        BleManagerService.shared.scanPeripheral(6)

        Log.d("connect st: \(String(describing: activeDevice.peripheral?.state.rawValue))")
    }

    func onPeripheralsFound(_ cbPeripheral: CBPeripheral, _ rssi: Int) {

        if cbPeripheral.name == nil {
            return
        }

        DispatchQueue.main.sync {
            if self.checkSamePeripheral(cbPeripheral) {
                return
            }
            self.deivces.append(cbPeripheral)
            self.tableView.reloadData()
        }
    }

    func onStopScan() {
        if self.refreshControl?.isRefreshing ?? false {
            self.refreshControl?.endRefreshing()
        }
    }

    func checkSamePeripheral(_ cbPeripheral: CBPeripheral) -> Bool {
        for c in deivces {
            if cbPeripheral.identifier.uuidString == c.identifier.uuidString {
                return true
            }
        }
        return false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deivces.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        DispatchQueue.main.async {
            Log.d("click : \(indexPath.row)")
            let uuid = self.deivces[indexPath.row].identifier.uuidString
            _ = BleManagerService.shared.connectPeripheral(uuid)
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = cellName

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = "\(deivces[indexPath.row].name!) / \(deivces[indexPath.row].identifier.uuidString)"
        
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
