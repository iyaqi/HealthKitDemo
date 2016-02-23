//
//  AddWorkOutViewController.swift
//  HealthKitDmo
//
//  Created by iyaqi on 16/2/22.
//  Copyright © 2016年 iyaqi. All rights reserved.
//

import UIKit
import HealthKit

class AddWorkOutViewController: UITableViewController ,UIPickerViewDelegate,UIPickerViewDataSource{
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    
    var datePicker:UIDatePicker?
    var pickerView:UIPickerView?
    var dateFommater:NSDateFormatter?
    var heathStore:HKHealthStore?
    
    var pickerViewData = ["running"]
    
    
    @IBAction func cancelAddWorkOut(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addWorkOut(sender: AnyObject) {
        
        self.heathStore = HKHealthStore()
        let distanceValue = Double(self.distanceLabel.text!)
        let energyValue = Double(self.energyLabel.text!)
        let distance = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: distanceValue!)
        let energy = HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: energyValue!)
        
        let endDate = self.dateFommater?.dateFromString(self.endDateLabel.text!)
        let startDate = self.dateFommater?.dateFromString(self.startDateLabel.text!)
        
        //这里我默认设置成running了。可以根据具体的类型再进行设置
        let workout = HKWorkout(activityType: .Running, startDate: startDate!, endDate: endDate!, workoutEvents: nil, totalEnergyBurned: energy, totalDistance: distance, metadata: nil)
        
        self.heathStore?.saveObject(workout, withCompletion: { (success, error) -> Void in
            if error != nil{
                print("添加错误")
                return
            }
            
            if success{
                print("添加成功")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.methodLabel.text = "running"
        
        self.dateFommater = NSDateFormatter()
        self.dateFommater?.dateStyle = .ShortStyle
        self.dateFommater?.timeStyle = .ShortStyle
        self.startDateLabel.text = self.dateFommater?.stringFromDate(NSDate())
        self.endDateLabel.text = self.dateFommater?.stringFromDate(NSDate())
        self.distanceLabel.text = "0"
        self.energyLabel.text = "0"
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.tableView.tableFooterView = UIView()
        
        switch indexPath.row{
            
        case 0:
            self.setupPickerView()
            
        case 1,2:
            self.setupDatePickerView(indexPath.row)
            
        case 3,4:
            self.setupAlertView(indexPath.row)
        default:
            break
        }
    }
    
    // MARK:
    func setupAlertView(index:Int){
        let alertView = UIAlertController(title: "添加信息", message: nil, preferredStyle: .Alert)
        
        alertView.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.keyboardType = .NumberPad
        }
        
        let action =  UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            
            if let text = alertView.textFields?.first?.text {
                if text.characters.count > 0 {
                    self.updateDistancOrEnergyLabel((text,index))
                }
            }
            
        }
        alertView.addAction(action)
        
        self .presentViewController(alertView, animated: true, completion: nil)
    }
    
    func updateDistancOrEnergyLabel(pragrams:(str:String,index:Int)){
        if pragrams.1 == 3{
            self.distanceLabel.text = pragrams.0
        }else if pragrams.1 == 4{
            self.energyLabel.text = pragrams.0
        }
    }
    
    // MARK: datePicker
    
    func setupDatePickerView(index:Int){
        self.datePicker = UIDatePicker()
        datePicker!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 200)
        self.tableView.tableFooterView = datePicker
        datePicker?.tag = index
        datePicker?.addTarget(self, action: Selector("selectDate:"), forControlEvents: .ValueChanged)
    }
    
    func selectDate(sender:AnyObject){
        print("selected time and date")
        let datePicker = sender as? UIDatePicker
        print("\((datePicker?.date)!)")
        
        //这里我就验证是否开始时间在结束时间之后，默认在正确的。
        if datePicker?.tag == 1{
            self.startDateLabel.text = self.dateFommater?.stringFromDate((datePicker?.date)!)
        }else if datePicker?.tag == 2{
            self.endDateLabel.text = self.dateFommater?.stringFromDate((datePicker?.date)!)
        }
    }
    
    //MARK: pickerView
    
    func setupPickerView(){
        self.pickerView = UIPickerView()
        pickerView!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 200)
        self.tableView.tableFooterView = pickerView
        pickerView?.delegate = self
        pickerView?.dataSource = self
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerViewData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedStr = self.pickerViewData[row]
        self.methodLabel.text = selectedStr
    }
    
}

