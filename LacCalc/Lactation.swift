//
//  Lactation.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/9/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class Lactation: NSObject, NSCoding {
    var date: NSDate
    var split: Split
    var lacticAcid: Double
    var strokeRate: Int?
    var dragFactor: Int?
    var heartRate: Int?

    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("lactations")
    
    init? (date: NSDate, split: Split, lacticAcid: Double, strokeRate: Int?, dragFactor: Int?, heartRate: Int?) {
        self.date = date
        self.split = split
        self.lacticAcid = lacticAcid
        self.strokeRate = strokeRate
        self.dragFactor = dragFactor
        self.heartRate = heartRate
        
        super.init()
        
        if (lacticAcid == 0) {
            return nil
        }
    }
    
    struct PropertyKey {
        static let dateKey = "date"
        static let splitKey = "split"
        static let lacticAcidKey = "lacticAcid"
        static let strokeRateKey = "strokeRate"
        static let dragFactorKey = "dragFactor"
        static let heartRateKey = "heartRate"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
        aCoder.encodeObject(split, forKey: PropertyKey.splitKey)
        aCoder.encodeDouble(lacticAcid, forKey: PropertyKey.lacticAcidKey)
        aCoder.encodeInteger((strokeRate)!, forKey: PropertyKey.strokeRateKey)
        aCoder.encodeInteger((dragFactor)!, forKey: PropertyKey.dragFactorKey)
        aCoder.encodeInteger((heartRate)!, forKey: PropertyKey.heartRateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        let split = aDecoder.decodeObjectForKey(PropertyKey.splitKey) as! Split
        let lacticAcid = aDecoder.decodeDoubleForKey(PropertyKey.lacticAcidKey)
        let strokeRate = aDecoder.decodeIntegerForKey(PropertyKey.strokeRateKey)
        let dragFactor = aDecoder.decodeIntegerForKey(PropertyKey.dragFactorKey)
        let heartRate = aDecoder.decodeIntegerForKey(PropertyKey.heartRateKey)
        
        self.init(date: date, split: split, lacticAcid: lacticAcid, strokeRate: strokeRate, dragFactor: dragFactor, heartRate: heartRate)
    }
}
