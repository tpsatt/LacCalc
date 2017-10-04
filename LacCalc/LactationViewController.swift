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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        if let lactation = lactation {
            let dateString = dateFormatter.string(from: lactation.date as Date)
            navigationItem.title = dateString
            dateLabel.text = dateString
            splitMinute.text = String(lactation.split.minutes)
            splitSecond.text = String(lactation.split.seconds)
            splitTenth.text = String(lactation.split.tenths)
            lactateLevel.text = String(format: "%.1f", lactation.lacticAcid)
            if (lactation.strokeRate != 0) { strokeRate.text = String(lactation.strokeRate!) }
            if (lactation.dragFactor != 0) { dragFactor.text = String(lactation.dragFactor!) }
            if (lactation.heartRate != 0) {
                heartRateLabel.text = String(lactation.heartRate!)
                heartButton.setImage(UIImage(named: "heartFilledIcon"), for: .normal)
            }
        } else {
            dateLabel.text = dateFormatter.string(from: Date())
        }
        
        dateView.frame.size.height = 45
        
        let displayTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.convertLabelUnits))
        displayView.isUserInteractionEnabled = true
        displayView.addGestureRecognizer(displayTap)
        datePicker.addTarget(self, action: #selector(ViewController.datePickerChanged(_:)), for: UIControlEvents.valueChanged)
        let dateTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.showDatePicker))
        dateView.isUserInteractionEnabled = true
        dateView.addGestureRecognizer(dateTap)
        let viewTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboards))
        view.addGestureRecognizer(viewTap)
        datePicker.date = dateFormatter.date(from: dateLabel.text!)!
        let splitTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editSplit))
        splitView.isUserInteractionEnabled = true
        splitView.addGestureRecognizer(splitTap)
        let lacticAcidTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editLacticAcid))
        lacticAcidView.isUserInteractionEnabled = true
        lacticAcidView.addGestureRecognizer(lacticAcidTap)
        let strokeRateTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editStrokeRate))
        strokeRateView.isUserInteractionEnabled = true
        strokeRateView.addGestureRecognizer(strokeRateTap)
        let dragFactorTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.editDragFactor))
        dragFactorView.isUserInteractionEnabled = true
        dragFactorView.addGestureRecognizer(dragFactorTap)
        splitOrigin = splitView.frame.origin.y
        scrollView.contentSize.height = 344
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func keyboardWillShow(_ notification : Notification) {
        var info = (notification as NSNotification).userInfo!
        var keyboardFrame : CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(_ notification : Notification) {
        
    }
    
    func datePickerChanged(_ datePicker:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateLabel.text = dateFormatter.string(from: datePicker.date)
        if (navigationItem.title != "New Lactic Acid Test") {
            navigationItem.title = dateFormatter.string(from: datePicker.date)
        }
    }
    
    func showDatePicker() {
        dismissKeyboards()
        UIView.animate(withDuration: 0.25, animations: {
            self.dateView.frame.size.height = 269
            self.splitView.frame.origin.y = self.splitOrigin+224
            self.lacticAcidView.frame.origin.y = self.splitOrigin+224+45+8
            self.optionalLabel.frame.origin.y = self.splitOrigin+224+45+8+45+8
            self.strokeRateView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8
            self.dragFactorView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8+45+8
            self.buttonsStackView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8+45+8+45+8
            self.displayView.frame.origin.y = self.splitOrigin+224+45+8+45+8+14+8+45+8+45+8+33+8
        }) 
        datePicker.isHidden = false
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
        datePicker.isHidden = true
        UIView.animate(withDuration: 0.25, animations: {
            self.dateView.frame.size.height = 45
            self.splitView.frame.origin.y = self.splitOrigin
            self.lacticAcidView.frame.origin.y = self.splitOrigin+45+8
            self.optionalLabel.frame.origin.y = self.splitOrigin+45+8+45+8
            self.strokeRateView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8
            self.dragFactorView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8+45+8
            self.buttonsStackView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8+45+8+45+8
            self.displayView.frame.origin.y = self.splitOrigin+45+8+45+8+14+8+45+8+45+8+33+8
        }) 
        scrollView.contentSize.height = 344
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddLactationMode = presentingViewController is UINavigationController
        if (isPresentingInAddLactationMode) {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let date = datePicker.date
        let lacticAcid = Double(lactateLevel.text!) ?? 0
        let split = Split(minutes: Int(splitMinute.text!) ?? 0, seconds: Int(splitSecond.text!) ?? 0, tenths: Int(splitTenth.text!) ?? 0)
        let spm = Int(strokeRate.text!) ?? 0
        let drag = Int(dragFactor.text!) ?? 0
        let heart = Int(heartRateLabel.text!) ?? 0
            
        lactation = Lactation(date: date, split: split, lacticAcid: lacticAcid, strokeRate: spm, dragFactor: drag, heartRate: heart)
    }
    
    @IBAction func calculate (_ sender:UIButton) {
        
        let lactate:Double = Double(lactateLevel.text!) ?? 0
        let minute:Int = Int(splitMinute.text!) ?? 0
        let second:Int = Int(splitSecond.text!) ?? 0
        let tenth:Int = Int(splitTenth.text!) ?? 0
        let split:Split = Split(minutes: minute, seconds: second, tenths: tenth)
        
        dismissKeyboards()
        
        if (splitMinute.text!.isEmpty && splitSecond.text!.isEmpty && splitTenth.text!.isEmpty) {
            let alert = UIAlertController(title: "No Split", message: "Please enter a value for your split.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in })
            self.present(alert, animated: true){}
        } else if (lactateLevel.text!.isEmpty) {
            let alert = UIAlertController(title: "No Lactic Acid", message: "Please enter a value for your lactic acid level.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in })
            self.present(alert, animated: true){}
        } else if (displayView.isHidden == false) {
            displayView.isHidden = true
        } else {
            calculationIsPerformed = true
            displayIsSplit = true
            displayPrompt.text = "Corrected split"
            finalSplitString = split.performLacticAcidCalculation(lactate).convertToString()
            finalWattsString = String(format: "%.1f",split.performLacticAcidCalculation(lactate).convertToWatts())
            display.text = finalSplitString;
            displayView.isHidden = false
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
        if let sourceViewController = sender.source as? HeartRateViewController, let heartRate = sourceViewController.heartRate {
            heartRateLabel.text = heartRate
            heartButton.setImage(UIImage(named: "heartFilledIcon"), for: UIControlState())
        }
        if let sourceViewController = sender.source as? PM5ViewController, let avgSplit = sourceViewController.avgSplit, let spm = sourceViewController.strokeRate, let drag = sourceViewController.avgDrag {
            var splitMinutesArray = avgSplit.components(separatedBy: ":")
            splitMinute.text = splitMinutesArray[0]
            var splitSecondsArray = splitMinutesArray[1].components(separatedBy: ".")
            splitSecond.text = splitSecondsArray[0]
            splitTenth.text = splitSecondsArray[1]
            strokeRate.text = spm
            dragFactor.text = drag
        }
        
    }


}

