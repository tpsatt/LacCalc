//
//  HeartRateViewController.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 2/6/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit
import CoreBluetooth

class HeartRateViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITextFieldDelegate {
    
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = "Searching for Bluetooth heart rate monitors..."
        heartRateBPM.text = "---"
        saveButton.isEnabled = false
        let viewTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeartRateViewController.dismissKeyboards))
        view.addGestureRecognizer(viewTap)
        let manualTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeartRateViewController.manualViewTap))
        manualView.isUserInteractionEnabled = true
        manualView.addGestureRecognizer(manualTap)
        manualHeartRate.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var heartRateBPM: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var manualHeartRate: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bluetoothView: UIView!
    @IBOutlet weak var manualView: UIView!
    var heartRate: String!
    
    @IBAction func segmentedControlChanged(_ sender : AnyObject) {
        saveButton.isEnabled = false
        if (segmentedControl.selectedSegmentIndex == 0) {
            manualView.isHidden = true
            bluetoothView.isHidden = false
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            bluetoothView.isHidden = true
            manualView.isHidden = false
            if (manualHeartRate.text != "") {
                saveButton.isEnabled = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (manualHeartRate.text != "") {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func manualViewTap() {
        manualHeartRate.becomeFirstResponder()
    }
    
    func dismissKeyboards() {
        manualHeartRate.resignFirstResponder()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            let serviceUUIDs:[CBUUID] = [CBUUID(string: "180D")]
            let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs)
            if lastPeripherals.count > 0 {
                let device = lastPeripherals.last as CBPeripheral!
                connectingPeripheral = device
                centralManager.connect(connectingPeripheral, options: nil)
            } else {
                centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
            }
        default:
            print(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        connectingPeripheral = peripheral
        connectingPeripheral.delegate = self
        centralManager.connect(connectingPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let actualError = error {
            print(actualError)
        } else {
            for service in peripheral.services as [CBService]! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let actualError = error {
            print(actualError)
        } else {
            if service.uuid == CBUUID(string: "180D") {
                for characteristic in service.characteristics as [CBCharacteristic]! {
                    switch characteristic.uuid.uuidString {
                    case "2A37":
                        print("Found heart rate measurement characteristic")
                        statusLabel.text = "Connected!"
                        peripheral.setNotifyValue(true, for: characteristic)
                    case "2A38":
                        print("Found body sensor location characteristic")
                        peripheral.readValue(for: characteristic)
                    case "2A39":
                        print("Found heart rate control point characteristic")
                        var rawArray:[UInt8] = [0x01]
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                    default:
                        print("")
                    }
                }
            }
        }
    }
    
    func update(_ heartRateData:Data) {
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        (heartRateData as NSData).getBytes(&buffer, length: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2) {
            if (buffer[0] & 0x01 == 0) {
                bpm = UInt16(buffer[1]);
            } else {
                bpm = UInt16(buffer[1]) << 8
                bpm = bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBPM = bpm {
            heartRateBPM.text = String(actualBPM)
            saveButton.isEnabled = true
        } else {
            heartRateBPM.text = String(describing: bpm)
            saveButton.isEnabled = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let actualError = error {
            print(actualError)
        } else {
            switch characteristic.uuid.uuidString {
            case "2A37":
                update(characteristic.value!)
            default:
                print("")
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func prepare(for segue: UIStoryboardSegue, sender: UIBarButtonItem) {
        if (saveButton === sender) {
            if (manualView.isHidden == false) {
                heartRate = manualHeartRate.text!
            } else if (bluetoothView.isHidden == false) {
                heartRate = heartRateBPM.text!
            }
        }
    }

}
