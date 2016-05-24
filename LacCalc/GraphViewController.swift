//
//  GraphViewController.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/12/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var frame: CGRect = maxSplitLabel.frame
        frame.origin.x = 31
        frame.origin.y = 60
        maxSplitLabel.frame = frame

        setUpGraph()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var splitGraphView : GraphView!
    @IBOutlet weak var maxSplitLabel : UILabel!
    @IBOutlet weak var minSplitLabel : UILabel!
    @IBOutlet weak var minSplitDate : UILabel!
    @IBOutlet weak var maxSplitDate : UILabel!
    @IBOutlet weak var wattsGraphView : GraphView!
    @IBOutlet weak var maxWattsLabel : UILabel!
    @IBOutlet weak var minWattsLabel : UILabel!
    @IBOutlet weak var minWattsDate : UILabel!
    @IBOutlet weak var maxWattsDate : UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        scrollView.contentSize.height = splitGraphView.bounds.height + wattsGraphView.bounds.height + 30
    }
    
    func setUpGraph() {
        
        var lactations:[Lactation] = (NSKeyedUnarchiver.unarchiveObjectWithFile(Lactation.ArchiveURL.path!) as? [Lactation])!
        
        wattsGraphView.yPoints.removeAll()
        wattsGraphView.xPoints.removeAll()
        splitGraphView.yPoints.removeAll()
        splitGraphView.xPoints.removeAll()
        
        for i in 0..<lactations.count {
            wattsGraphView.yPoints.append(Int(lactations[i].split.performLacticAcidCalculation(lactations[i].lacticAcid).convertToWatts()*10))
            wattsGraphView.xPoints.append(Int(lactations[i].date.timeIntervalSince1970))
            splitGraphView.yPoints.append(Int(lactations[i].split.performLacticAcidCalculation(lactations[i].lacticAcid).convertToSeconds()*10))
            splitGraphView.xPoints.append(Int(lactations[i].date.timeIntervalSince1970))
        }
        
        maxWattsLabel.text = "\(wattsGraphView.yPoints.maxElement()!/10)"
        minWattsLabel.text = "\(wattsGraphView.yPoints.minElement()!/10)"
        var maxSplit:String = Split.convertSecondsToSplit(Double(splitGraphView.yPoints.maxElement()!/10))
        var minSplit:String = Split.convertSecondsToSplit(Double(splitGraphView.yPoints.minElement()!/10))
        maxSplit = String(maxSplit.characters.dropLast())
        maxSplit = String(maxSplit.characters.dropLast())
        minSplit = String(minSplit.characters.dropLast())
        minSplit = String(minSplit.characters.dropLast())
        maxSplitLabel.text = maxSplit
        minSplitLabel.text = minSplit
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        minSplitDate.text = dateFormatter.stringFromDate(lactations[0].date)
        maxSplitDate.text = dateFormatter.stringFromDate(lactations[lactations.count-1].date)
        minWattsDate.text = dateFormatter.stringFromDate(lactations[0].date)
        maxWattsDate.text = dateFormatter.stringFromDate(lactations[lactations.count-1].date)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        scrollView.contentSize.height = splitGraphView.bounds.height + wattsGraphView.bounds.height + 30
    }


}
