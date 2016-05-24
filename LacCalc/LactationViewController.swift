//
//  ViewController.swift
//  LacCalc
//
//  Created by Toby Satterthwaite on 1/7/16.
//  Copyright © 2016 Thomas Satterthwaite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        if let lactation = lactation {
            let dateString = dateFormatter.stringFromDate(lactation.date)
            navigationItem.title = dateString
            dateLabel.text = dateString
            splitMinute.text = NSString(format: "%i", lactation.split.minutes) as String
            splitSecond.text = NSString(format: "%i", lactation.split.seconds) as String
            splitTenth.text = NSString(format: "%i", lactation.split.tenths) as String
            lactateLevel.text = NSString(format: "%.1f", lactation.lacticAcid) as String
            if (lactation.strokeRate != 0) { strokeRate.text = NSString(format: "%i", lactation.strokeRate!) as String }
            if (lactation.dragFactor != 0) { dragFactor.text = NSString(format: "%i", lactation.dragFactor!) as String }
            if (lactation.heartRate != 0) {
                heartRateLabel.text = NSString(format: "%i", lactation.heartRate!) as String
                heartButton.setImage(UIImage(named: "heartFilledIcon"), forState: UIControlState.Normal)
            }
        } else {
            dateLabel.text = dateFormatter.stringFromDate(NSDate())
        }
        
        dateView.frame.size.height = 45
        
        let displayTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.convertLabelUnits))
        displayView.userInteractionEnabled = true
        displayView.addGestureRecognizer(displayTap)
        datePicker.addTarget(self, action: #selector(ViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        let dateTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.showDatePicker))
        dateView.userInteractionEnabled = true
        dateView.addGestureRecognizer(dateTap)
        let viewTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboards))
        view.addGestureRecognizer(viewTap)
        datePicker.date = dateFormatter.dateFromString(dateLabel.text!)!
        let splitTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editSplit))
        splitView.userInteractionEnabled = true
        splitView.addGestureRecognizer(splitTap)
        let lacticAcidTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editLacticAcid))
        lacticAcidView.userInteractionEnabled = true
        lacticAcidView.addGestureRecognizer(lacticAcidTap)
        let strokeRateTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editStrokeRate))
        strokeRateView.userInteractionEnabled = true
        strokeRateView.addGestureRecognizer(strokeRateTap)
        let dragFactorTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editDragFactor))
        dragFactorView.userInteractionEnabled = true
        dragFactorView.addGestureRecognizer(dragFactorTap)
        splitOrigin = splitView.frame.origin.y
        scrollView.contentSize.height = 344
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var display : UILabel!
    @IBOutlet weak var displayPrompt : UILabel!
    @IBOutlet weak var splitMinute : UITextField!
    @IBOutlet weak var splitSecond : UITextField!
    @IBOutlet weak var splitTenth : UITextField!
    @IBOutlet weak var lactateLevel : UITextField!
    @IBOutlet weak var strokeRate : UITextField!
    @IBOutlet weak var dragFactor : UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var splitView: UIView!
    @IBOutlet weak var lacticAcidView: UIView!
    @IBOutlet weak var strokeRateView: UIView!
    @IBOutlet weak var dragFactorView: UIView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var optionalLabel: UILabel!
    @IBOutlet weak var calculatorButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    var finalWattsString = "0"
    var finalSplitString = "0:00.0"
    var displayIsSplit = true
    var calculationIsPerformed = false
    var lactation:Lactation?
    var splitOrigin:CGFloat!
    
    func keyboardWillShow(notification : NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame : CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification : NSNotification) {
        
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateLabel.text = dateFormatter.stringFromDate(datePicker.date)
        if (navigationItem.title != "New Lactic Acid Test") {
            navigationItem.title = dateFormatter.stringFromDate(datePicker.date)
        }
    }
    
    func showDatePicker() {
        dismissKeyboards()
        UIView.animateWithDuration(0.25) {
            self.dateView.frame.size.height = 269
            self.splitView.frame.origin.y = self.splitOrigin+224
            self.lacticAcidView.frame.origin.y = self.splitOrigin+224+45+8
            self.optionalLabel.frame.origin.y = self.splitOrigin+224+45+8+45+8
            self.strokeRateView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8
            self.dragFactorView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8+45+8
            self.buttonsStackView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8+45+8+45+8
            self.displayView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8+45+8+45+8+33+8
        }
        datePicker.hidden = false
        scrollView.contentSize.height = 621
        
    }
    
    func editSplit() {
        dismissKeyboards()
        splitMinute.becomeFirstResponder()
    }
    
    func editLacticAcid() {
        dismissKeyboards()
        lactateLevel.becomeFirstResponder()
    }
    
    func editStrokeRate() {
        dismissKeyboards()
        strokeRate.becomeFirstResponder()
    }
    
    func editDragFactor() {
        dismissKeyboards()
        dragFactor.becomeFirstResponder()
    }
    
    func dismissKeyboards() {
        splitMinute.resignFirstResponder()
        splitSecond.resignFirstResponder()
        splitTenth.resignFirstResponder()
        lactateLevel.resignFirstResponder()
        strokeRate.resignFirstResponder()
        dragFactor.resignFirstResponder()
        datePicker.hidden = true
        UIView.animateWithDuration(0.25) {
            self.dateView.frame.size.height = 45
            self.splitView.frame.origin.y = self.splitOrigin
            self.lacticAcidView.frame.origin.y = self.splitOrigin+45+8
            self.optionalLabel.frame.origin.y = self.splitOrigin+45+8+45+8
            self.strokeRateView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8
            self.dragFactorView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8+45+8
            self.buttonsStackView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8+45+8+45+8
            self.displayView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8+45+8+45+8+33+8
        }
        scrollView.contentSize.height = 344
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddLactationMode = presentingViewController is UINavigationController
        if (isPresentingInAddLactationMode) {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (saveButton === sender) {
            let date = datePicker.date
            let lacticAcid = NSString(string:lactateLevel.text!).doubleValue
            let split = Split(minutes: NSString(string: splitMinute.text!).integerValue, seconds: NSString(string: splitSecond.text!).integerValue, tenths: NSString(string: splitTenth.text!).integerValue)
            let spm = NSString(string: strokeRate.text!).integerValue
            let drag = NSString(string: dragFactor.text!).integerValue
            let heart = NSString(string: heartRateLabel.text!).integerValue
            
            lactation = Lactation(date: date, split: split, lacticAcid: lacticAcid, strokeRate: spm, dragFactor: drag, heartRate: heart)
        }
    }
    
    @IBAction func calculate (sender:UIButton) {
        let lactate:Double = NSString(string:lactateLevel.text!).doubleValue
        let minute:Int = NSString(string: splitMinute.text!).integerValue
        let second:Int = NSString(string: splitSecond.text!).integerValue
        let tenth:Int = NSString(string: splitTenth.text!).integerValue
        let split:Split = Split(minutes: minute, seconds: second, tenths: tenth)
        
        dismissKeyboards()
        
        if (splitMinute.text!.isEmpty && splitSecond.text!.isEmpty && splitTenth.text!.isEmpty) {
            let alert = UIAlertController(title: "No Split", message: "Please enter a value for your split.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default){ _ in })
            self.presentViewController(alert, animated: true){}
        } else if (lactateLevel.text!.isEmpty) {
            let alert = UIAlertController(title: "No Lactic Acid", message: "Please enter a value for your lactic acid level.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default){ _ in })
            self.presentViewController(alert, animated: true){}
        } else if (displayView.hidden == false) {
            displayView.hidden = true
        } else {
            calculationIsPerformed = true
            displayIsSplit = true
            displayPrompt.text = "Corrected split"
            finalSplitString = split.performLacticAcidCalculation(lactate).convertToString()
            finalWattsString = String(format: "%.1f",split.performLacticAcidCalculation(lactate).convertToWatts())
            display.text = finalSplitString;
            displayView.hidden = false
        }
    }
    
    func convertLabelUnits() {
        if (calculationIsPerformed) {
            if (displayIsSplit) {
                displayPrompt.text = "Corrected watts"
                display.text = finalWattsString
                displayIsSplit = false
            } else {
                displayPrompt.text = "Corrected split"
                display.text = finalSplitString
                displayIsSplit = true
            }
        }
    }
    
    @IBAction func unwindToAddLactation(sender:UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? HeartRateViewController, heartRate = sourceViewController.heartRate {
            heartRateLabel.text = heartRate
            heartButton.setImage(UIImage(named: "heartFilledIcon"), forState: UIControlState.Normal)
        }
        if let sourceViewController = sender.sourceViewController as? PM5ViewController, avgSplit = sourceViewController.avgSplit, spm = sourceViewController.strokeRate, drag = sourceViewController.avgDrag {
            var splitMinutesArray = avgSplit.componentsSeparatedByString(":")
            splitMinute.text = splitMinutesArray[0]
            var splitSecondsArray = splitMinutesArray[1].componentsSeparatedByString(".")
            splitSecond.text = splitSecondsArray[0]
            splitTenth.text = splitSecondsArray[1]
            strokeRate.text = spm
            dragFactor.text = drag
        }
        
    }


}

