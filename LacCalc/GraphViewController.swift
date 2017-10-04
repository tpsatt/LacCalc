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
    
    func setUpGraph() {
        
        var lactations: [Lactation] = NSKeyedUnarchiver.unarchiveObject(withFile: Lactation.ArchiveURL.path) as! [Lactation]
        
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
        
        maxWattsLabel.text = "\(wattsGraphView.yPoints.max()!/10)"
        minWattsLabel.text = "\(wattsGraphView.yPoints.min()!/10)"
        var maxSplit:String = Split.convertSecondsToSplit(Double(splitGraphView.yPoints.max()!/10))
        var minSplit:String = Split.convertSecondsToSplit(Double(splitGraphView.yPoints.min()!/10))
        maxSplit = String(maxSplit.characters.dropLast())
        maxSplit = String(maxSplit.characters.dropLast())
        minSplit = String(minSplit.characters.dropLast())
        minSplit = String(minSplit.characters.dropLast())
        maxSplitLabel.text = maxSplit
        minSplitLabel.text = minSplit
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        minSplitDate.text = dateFormatter.string(from: lactations[0].date as Date)
        maxSplitDate.text = dateFormatter.string(from: lactations[lactations.count-1].date as Date)
        minWattsDate.text = dateFormatter.string(from: lactations[0].date as Date)
        maxWattsDate.text = dateFormatter.string(from: lactations[lactations.count-1].date as Date)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
