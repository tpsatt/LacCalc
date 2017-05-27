//
//  Lactation.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/9/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class Lactation: NSObject, NSCoding {
    var date: Date
    var split: Split
    var lacticAcid: Double
    var strokeRate: Int?
    var dragFactor: Int?
    var heartRate: Int?

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("lactations")
    
    init? (date: Date, split: Split, lacticAcid: Double, strokeRate: Int?, dragFactor: Int?, heartRate: Int?) {
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        aCoder.encode(split, forKey: PropertyKey.splitKey)
        aCoder.encode(lacticAcid, forKey: PropertyKey.lacticAcidKey)
        aCoder.encode((strokeRate)!, forKey: PropertyKey.strokeRateKey)
        aCoder.encode((dragFactor)!, forKey: PropertyKey.dragFactorKey)
        aCoder.encode((heartRate)!, forKey: PropertyKey.heartRateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as! Date
        let split = aDecoder.decodeObject(forKey: PropertyKey.splitKey) as! Split
        let lacticAcid = aDecoder.decodeDouble(forKey: PropertyKey.lacticAcidKey)
        let strokeRate = aDecoder.decodeInteger(forKey: PropertyKey.strokeRateKey)
        let dragFactor = aDecoder.decodeInteger(forKey: PropertyKey.dragFactorKey)
        let heartRate = aDecoder.decodeInteger(forKey: PropertyKey.heartRateKey)
        
        self.init(date: date, split: split, lacticAcid: lacticAcid, strokeRate: strokeRate, dragFactor: dragFactor, heartRate: heartRate)
    }
}
