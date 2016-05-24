//
//  LactationTableViewController.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/9/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class LactationTableViewController: UITableViewController {
    
    var lactations = [Lactation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 72.0/255.0, green: 85.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        //navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        if let savedLactations = loadLactations() {
            lactations += savedLactations
        } else {
            loadSampleLactations()
        }
    }
    
    func loadSampleLactations() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let date1 = dateFormatter.dateFromString("September 21, 2015")
        let date2 = dateFormatter.dateFromString("October 4, 2015")
        let date3 = dateFormatter.dateFromString("January 7, 2016")
        let split1 = Split(minutes: 1, seconds: 57, tenths: 2)
        let split2 = Split(minutes: 1, seconds: 55, tenths: 5)
        let split3 = Split(minutes: 1, seconds: 54, tenths: 5)
        let lactation1 = Lactation(date: date1!, split: split1, lacticAcid: 1.6, strokeRate: 0, dragFactor: 0, heartRate: 0)!
        let lactation2 = Lactation(date: date2!, split: split2, lacticAcid: 2.0, strokeRate: 0, dragFactor: 0, heartRate: 0)!
        let lactation3 = Lactation(date: date3!, split: split3, lacticAcid: 1.7, strokeRate: 0, dragFactor: 0, heartRate: 0)!
        
        lactations += [lactation1, lactation2, lactation3]
    }
    
    func getLactations() -> [Lactation] {
        return lactations
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lactations.count
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "LactationTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LactationTableViewCell
        
        let lactation = lactations[indexPath.row]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let dateString = dateFormatter.stringFromDate(lactation.date)
        
        cell.dateLabel.text = dateString
        cell.descriptionLabel.text = String(format: "%@ at %.1f mmol/L",lactation.split.convertToString(),lactation.lacticAcid)

        return cell
    }
    
    @IBAction func unwindToLactationList(sender:UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ViewController, lactation = sourceViewController.lactation {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                lactations[selectedIndexPath.row] = lactation
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            } else {
                let newIndexPath = NSIndexPath(forRow: lactations.count, inSection: 0)
                lactations.append(lactation)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            
            saveLactations()
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            lactations.removeAtIndex(indexPath.row)
            saveLactations()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        lactations.insert(lactations.removeAtIndex(fromIndexPath.row), atIndex: toIndexPath.row)
        saveLactations()
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowDetail") {
            let lactationDetailViewController = segue.destinationViewController as! ViewController
            if let selectedLactationCell = sender as? LactationTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedLactationCell)!
                let selectedLactation = lactations[indexPath.row]
                lactationDetailViewController.lactation = selectedLactation
            }
        } else if (segue.identifier == "AddItem") {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    func saveLactations() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(lactations, toFile: Lactation.ArchiveURL.path!)
        
        if (!isSuccessfulSave) {
            print("Failed to save lactations")
        }
    }
    
    func loadLactations() -> [Lactation]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Lactation.ArchiveURL.path!) as? [Lactation]
    }

}
