//
//  PM5ViewController.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 3/14/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit
import CoreBluetooth

class PM5ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var central: CBCentral!
    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = "0:00"
        distanceLabel.text = "0"
        strokeRateLabel.text = "0"
        splitLabel.text = "0:00"
        avgSplitLabel.text = "0:00.0"
        driveLengthLabel.text = "0m"
        strokeCountLabel.text = "0"
        driveTimeLabel.text = "0s"
        recoveryTimeLabel.text = "0s"
        ratioLabel.text = "0"
        peakForceLabel.text = "0 lbs."
        avgForceLabel.text = "0 lbs."
        advancedView.hidden = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var strokeRateLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var avgSplitLabel: UILabel!
    @IBOutlet weak var driveLengthLabel: UILabel!
    @IBOutlet weak var driveTimeLabel: UILabel!
    @IBOutlet weak var recoveryTimeLabel: UILabel!
    @IBOutlet weak var strokeDistanceLabel: UILabel!
    @IBOutlet weak var peakForceLabel: UILabel!
    @IBOutlet weak var avgForceLabel: UILabel!
    @IBOutlet weak var strokeCountLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var simpleView: UIView!
    @IBOutlet weak var advancedView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var dragFactor:Int = 0
    var avgDrag: String!
    var avgSplit: String!
    var strokeRate: String!
    
    @IBAction func segmentedControlChanged(sender : AnyObject) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            simpleView.hidden = false
            advancedView.hidden = true
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            simpleView.hidden = true
            advancedView.hidden = false
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            central.scanForPeripheralsWithServices([CBUUID(string: "CE060000-43E5-11E4-916C-0800200C9A66")], options: nil)
        default:
            print(central.state)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        central.stopScan()
        central.connectPeripheral(peripheral, options: nil)
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
            if service.UUID == CBUUID(string: "CE060000-43E5-11E4-916C-0800200C9A66") {
                for characteristic in service.characteristics as [CBCharacteristic]! {
                    switch characteristic.UUID.UUIDString {
                    case "0x0031":
                        print("Found 0x0031 data packet characteristic")
                        navigationItem.title = "Connected to PM5"
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    case "0x0032":
                        print("Found 0x0032 data packet characteristic")
                        navigationItem.title = "Connected to PM5"
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    case "0x0035":
                        print("Found 0x0035 data packet characteristic")
                        navigationItem.title = "Connected to PM5"
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    default:
                        print("")
                    }
                }
            }
        }
    }
    
    func dataToUnsignedBytes32(value: NSData) -> [UInt32] {
        let count = value.length
        var array = [UInt32](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count*sizeof(UInt32))
        
        return array
    }
    
    func updateBasic(PM5Data: NSData) {
        let dataFromRowing = dataToUnsignedBytes32(PM5Data)
        let distance:Double = Double(dataFromRowing[5]) * 65536 + Double(dataFromRowing[4]) * 256 + Double(dataFromRowing[3])
        distanceLabel.text = String(distance)
        let time:Double = Double(dataFromRowing[2]) * 65536 + Double(dataFromRowing[1]) * 256 + Double(dataFromRowing[0])
        timeLabel.text = String(time)
        let goalTime:Double = 12000
        progressBar.progress = Float(time/goalTime)
        let drag:Double = Double(dataFromRowing[18])
        dragFactor = Int(drag)
    }
    
    func updateIntermediate(PM5Data: NSData) {
        let dataFromRowing = dataToUnsignedBytes32(PM5Data)
        let strokeRate = Double(dataFromRowing[5])
        strokeRateLabel.text = String(strokeRate)
        let split = Double(dataFromRowing[8]) * 256 + Double(dataFromRowing[7])
        splitLabel.text = String(split)
        let avgSplit = Double(dataFromRowing[10]) * 256 + Double(dataFromRowing[9])
        avgSplitLabel.text = String(avgSplit)
    }
    
    func updateAdvanced(PM5Data: NSData) {
        let dataFromRowing = dataToUnsignedBytes32(PM5Data)
        let driveLength = Double(dataFromRowing[6])
        driveLengthLabel.text = String(driveLength)
        let driveTime = Double(dataFromRowing[7])
        driveTimeLabel.text = String(driveTime)
        let recoveryTime = Double(dataFromRowing[9]) * 256 + Double(dataFromRowing[8])
        recoveryTimeLabel.text = String(recoveryTime)
        let ratio = driveTime/recoveryTime
        ratioLabel.text = String(ratio)
        let strokeDistance = Double(dataFromRowing[11]) * 256 + Double(dataFromRowing[10])
        strokeDistanceLabel.text = String(strokeDistance)
        let peakForce = Double(dataFromRowing[13]) * 256 + Double(dataFromRowing[12])
        peakForceLabel.text = String(peakForce)
        let avgForce = Double(dataFromRowing[15]) * 256 + Double(dataFromRowing[14])
        avgForceLabel.text = String(avgForce)
        let strokeCount = Double(dataFromRowing[17]) * 256 + Double(dataFromRowing[16])
        strokeCountLabel.text = String(strokeCount)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let actualError = error {
            print(actualError)
        } else {
            switch characteristic.UUID.UUIDString {
            case "0x0031":
                updateBasic(characteristic.value!)
            case "0x0032":
                updateIntermediate(characteristic.value!)
            case "0x0035":
                updateAdvanced(characteristic.value!)
            default:
                print("")
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (saveButton === sender) {
            avgSplit = avgSplitLabel.text!
            strokeRate = strokeRateLabel.text!
            avgDrag = String(dragFactor)
        }
    }

}
