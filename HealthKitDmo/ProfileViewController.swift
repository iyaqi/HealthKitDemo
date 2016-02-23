//
//  ProfileViewController.swift
//  HealthKitDmo
//
//  Created by iyaqi on 16/2/18.
//  Copyright © 2016年 iyaqi. All rights reserved.
//

import UIKit
import HealthKit


class ProfileViewController: UITableViewController {
    
    let kUnKnowString = "unknow"
    var height,weight:HKQuantitySample?
    var healthStore:HKHealthStore?
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var BMILabel: UILabel!
    
    
    var healthManager:HealthManager?
    
    override func viewDidLoad() {
        
        let  profile = healthManager?.readProfile()
        self.healthStore = HKHealthStore()
        
        ageLabel.text = profile?.age == nil ? kUnKnowString:String(profile!.age!)
        sexLabel.text = biologicSexLiteral(profile?.biologicalsex?.biologicalSex)
        bloodTypeLabel.text = bloodTypeLiteral(profile?.bloodType?.bloodType)
        
        updateWeight()
        updateHeight()
        
    }
    
    
    /**
     一个转化性别为字符串的方法
     - parameter biologicSex: hk类型的性别对象
     - returns: 一个性别字符串
     */
    func biologicSexLiteral(biologicSex:HKBiologicalSex?)->String{
        
        var sexStr = kUnKnowString
        
        if biologicSex != nil{
            switch biologicSex! {
            case .Female:
                sexStr = "female"
            case .Male :
                sexStr = "male"
            default:
                break
            }
        }
        
        return sexStr
    }
    
    /**
     雷同上面的方法，返回血型字符串
     
     */
    func bloodTypeLiteral(hkbloodType:HKBloodType?)->String{
        var bloodType = kUnKnowString
        
        if hkbloodType != nil{
            switch hkbloodType!{
            case .APositive:
                bloodType = "A+"
            case .ANegative:
                bloodType = "A-"
            case .BPositive:
                bloodType = "B+"
            case .BNegative:
                bloodType = "B-"
            case .ABPositive:
                bloodType = "AB+"
            case .ABNegative:
                bloodType = "AB-"
            case .OPositive:
                bloodType = "O+"
            case .ONegative:
                bloodType = "O-"
            default:
                break
            }
        }
        return bloodType
    }
    
    /**
     获取并更新体重
     */
    
    func updateWeight(){
        
        let weightSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
        self.healthManager?.fetchMostRecentSample(weightSampleType!, competion: { (mostRecentSample, error) -> Void in
            
            if error != nil {
                return
            }
            
            var weightString = self.kUnKnowString
            self.weight = mostRecentSample as? HKQuantitySample
            
            if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Kilo)){
                
                let weightFommater = NSMassFormatter()
                weightFommater.forPersonMassUse = true
                weightString = weightFommater.stringFromKilograms(kilograms)
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.weightLabel.text = weightString
                self.updateBMILabel()
            }
            
        })
    }
    
    /**
     获取并更新身高
     */
    func updateHeight(){
        //设置要查找的类型，根据标识符
        let heightSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
        
        //获取身高sample
        self.healthManager?.fetchMostRecentSample(heightSampleType!, competion: { (heightSample, error) -> Void in
            
            if error != nil {
                return
            }
            
            var heightStr = self.kUnKnowString
            self.height = heightSample as? HKQuantitySample
            
            if let kilograms =  self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()){
                
                heightStr = String(format: "%.2f", kilograms) + "m"
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.heightLabel.text = heightStr
                self.updateBMILabel()
            }
            
        })
    }
    
    /**
     获取并设置BMI:
     */
    func updateBMILabel(){
        
        let weight = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(HKMetricPrefix.Kilo))
        let height = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit())
        var bmiValue = 0.0
        if height == 0{
            
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            bmiValue = (weight!)/(height! * height!)
            self.BMILabel.text = String(format: "%.02f", bmiValue)
        }
        
        
    }
    
    
    @IBAction func addBMIData2HealthStore(sender: AnyObject) {
        
        
        let alertView = UIAlertController(title: "输入BMI值", message: nil, preferredStyle: .Alert)
        
        alertView.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.keyboardType = .NumberPad
        }
        
        let action =  UIAlertAction(title: "添加", style: .Default) { (action) -> Void in
            
            var value:Double?
            
            if let text = alertView.textFields?.first?.text {
                if text.characters.count > 0 {
                    value = Double(text)
                    self.saveBMI2HealthStore(value!)
                }
            }
        }
        alertView.addAction(action)
        
        self .presentViewController(alertView, animated: true, completion: nil)
    }
    
    
    func saveBMI2HealthStore(height:Double){
        
        let BMIType =  HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
        
        let BMIQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: height)
        
        let now = NSDate()
        
        let BMISample =  HKQuantitySample(type: BMIType!, quantity: BMIQuantity, startDate: now, endDate: now)
        
        self.healthStore?.saveObject(BMISample, withCompletion: { (success, error) -> Void in
            
            if success {
                print("添加成功")
                self.updateWeight()
            }
            
            if (error != nil) {
                print("添加失败")
            }
        })
    }
    
    
}
