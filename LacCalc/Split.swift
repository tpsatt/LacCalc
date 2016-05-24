//
//  Split.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/11/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class Split: NSObject, NSCoding {
    
    var minutes: Int
    var seconds: Int
    var tenths: Int
    let goalLacticAcidLevel = 1.7
    
    init (minutes: Int, seconds: Int, tenths: Int) {
        self.minutes = minutes
        self.seconds = seconds
        self.tenths = tenths
        
        super.init()
    }
    
    init (fromWatts watts: Double) {
        var newSeconds = watts
        newSeconds = 2.80/newSeconds
        newSeconds = pow(newSeconds, 0.3333333333)
        newSeconds *= 500
        
        self.minutes = Int(newSeconds/60)
        let roundedSeconds:Int = self.minutes*60
        self.seconds = Int(newSeconds)-roundedSeconds
        var roundedPace:Int = Int(newSeconds)
        roundedPace *= 10
        let unroundedPace:Int = Int(newSeconds*10)
        self.tenths = unroundedPace-roundedPace
    }
    
    func convertToSeconds() -> Double {
        var pace: Double
        pace = Double(minutes)
        pace *= 60
        pace += Double(seconds)
        pace += Double(tenths)/10.0
        
        return pace
    }
    
    func convertToWatts() -> Double {
        var watts: Double
        watts = convertToSeconds()
        watts /= 500
        watts = pow(watts,3)
        watts = 2.80/watts
        
        return watts
    }
    
    func convertToString() -> String {
        var finalString: String
        if (seconds < 10) {
            finalString = String(format: "%i:0%i.%i", minutes, seconds, tenths)
        } else {
            finalString = String(format: "%i:%i.%i", minutes, seconds, tenths)
        }
        
        return finalString
    }
    
    func performLacticAcidCalculation(lacticAcidLevel: Double) -> Split {
        var newWatts:Double = self.convertToWatts()
        newWatts = pow(newWatts,8)
        newWatts *= goalLacticAcidLevel
        newWatts = newWatts/lacticAcidLevel
        newWatts = pow(newWatts,0.125)
        return Split(fromWatts: newWatts)
    }
    
    static func convertSecondsToSplit (seconds: Double) -> String {
        var finalString: String
        var finalMinutes: Int
        var finalSeconds: Int
        var finalTenths: Int
        finalMinutes = Int(seconds/60)
        finalSeconds = Int(seconds)
        finalSeconds -= finalMinutes*60
        finalTenths = Int(seconds*10)
        finalTenths -= Int(seconds)*10
        if (finalSeconds < 10) {
            finalString = String(format: "%i:0%i.%i", finalMinutes, finalSeconds, finalTenths)
        } else {
            finalString = String(format: "%i:%i.%i", finalMinutes, finalSeconds, finalTenths)
        }
        return finalString
    }
    
    struct PropertyKey {
        static let minutesKey = "minutes"
        static let secondsKey = "seconds"
        static let tenthsKey = "tenths"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(minutes, forKey: PropertyKey.minutesKey)
        aCoder.encodeInteger(seconds, forKey: PropertyKey.secondsKey)
        aCoder.encodeInteger(tenths, forKey: PropertyKey.tenthsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let minutes = aDecoder.decodeIntegerForKey(PropertyKey.minutesKey)
        let seconds = aDecoder.decodeIntegerForKey(PropertyKey.secondsKey)
        let tenths = aDecoder.decodeIntegerForKey(PropertyKey.tenthsKey)
        
        self.init(minutes: minutes, seconds: seconds, tenths: tenths)
    }
}
