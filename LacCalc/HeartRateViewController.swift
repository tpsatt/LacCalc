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
        saveButton.enabled = false
        let viewTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeartRateViewController.dismissKeyboards))
        view.addGestureRecognizer(viewTap)
        let manualTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HeartRateViewController.manualViewTap))
        manualView.userInteractionEnabled = true
        manualView.addGestureRecognizer(manualTap)
        manualHeartRate.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var heartRateBPM: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var manualHeartRate: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bluetoothView: UIView!
    @IBOutlet weak var manualView: UIView!
    var heartRate: String!
    
    @IBAction func segmentedControlChanged(sender : AnyObject) {
        saveButton.enabled = false
        if (segmentedControl.selectedSegmentIndex == 0) {
            manualView.hidden = true
            bluetoothView.hidden = false
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            bluetoothView.hidden = true
            manualView.hidden = false
            if (manualHeartRate.text != "") {
                saveButton.enabled = true
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (manualHeartRate.text != "") {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
        }
    }
    
    func manualViewTap() {
        manualHeartRate.becomeFirstResponder()
    }
    
    func dismissKeyboards() {
        manualHeartRate.resignFirstResponder()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            let serviceUUIDs:[CBUUID] = [CBUUID(string: "180D")]
            let lastPeripherals = centralManager.retrieveConnectedPeripheralsWithServices(serviceUUIDs)
            if lastPeripherals.count > 0 {
                let device = lastPeripherals.last as CBPeripheral!
                connectingPeripheral = device
                centralManager.connectPeripheral(connectingPeripheral, options: nil)
            } else {
                centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)
            }
        default:
            print(central.state)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        connectingPeripheral = peripheral
        connectingPeripheral.delegate = self
        centralManager.connectPeripheral(connectingPeripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let actualError = error {
            print(actualError)
        } else {
            for service in peripheral.services as [CBService]! {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let actualError = error {
            print(actualError)
        } else {
            if service.UUID == CBUUID(string: "180D") {
                for characteristic in service.characteristics as [CBCharacteristic]! {
                    switch characteristic.UUID.UUIDString {
                    case "2A37":
                        print("Found heart rate measurement characteristic")
                        statusLabel.text = "Connected!"
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    case "2A38":
                        print("Found body sensor location characteristic")
                        peripheral.readValueForCharacteristic(characteristic)
                    case "2A39":
                        print("Found heart rate control point characteristic")
                        var rawArray:[UInt8] = [0x01]
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    default:
                        print("")
                    }
                }
            }
        }
    }
    
    func update(heartRateData:NSData) {
        var buffer = [UInt8](count: heartRateData.length, repeatedValue: 0x00)
        heartRateData.getBytes(&buffer, length: buffer.count)
        
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
            saveButton.enabled = true
        } else {
            heartRateBPM.text = String(bpm)
            saveButton.enabled = true
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let actualError = error {
            print(actualError)
        } else {
            switch characteristic.UUID.UUIDString {
            case "2A37":
                update(characteristic.value!)
            default:
                print("")
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (saveButton === sender) {
            if (manualView.hidden == false) {
                heartRate = manualHeartRate.text!
            } else if (bluetoothView.hidden == false) {
                heartRate = heartRateBPM.text!
            }
        }
    }

}
