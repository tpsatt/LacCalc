//
//  Stroke.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 3/17/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class Stroke: NSObject {
    
    var split: Split
    var strokeRate: Double
    var driveLength: Double
    var strokeDistance: Double
    var driveTime: Double
    var recoveryTime: Double
    var ratio: Double
    var peakForce: Double
    var avgForce: Double
    
    init (split: Split, strokeRate: Double, driveLength: Double, strokeDistance: Double, driveTime: Double, recoveryTime: Double, peakForce: Double, avgForce: Double) {
        self.split = split
        self.strokeRate = strokeRate
        self.driveLength = driveLength
        self.strokeDistance = strokeDistance
        self.driveTime = driveTime
        self.recoveryTime = recoveryTime
        self.ratio = driveTime/recoveryTime
        self.peakForce = peakForce
        self.avgForce = avgForce
        
        super.init()
    }
    
}
