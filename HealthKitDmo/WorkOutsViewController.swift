//
//  WorkOutsViewController.swift
//  HealthKitDmo
//
//  Created by iyaqi on 16/2/18.
//  Copyright © 2016年 iyaqi. All rights reserved.
//

import UIKit
import HealthKit

class WorkOutsViewController: UITableViewController {
    
    var healthManager:HealthManager?
    var workOuts = [HKWorkout]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.healthManager?.fetchWorkOutsData({ (results, error) -> Void in
            
            if error != nil{
                print("获取失败")
            }else{
                self.workOuts = results as! [HKWorkout]
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            });
        })
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workOuts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier =  "workouts"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil{
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: identifier)
        }
        
        //日期
        let workOut = self.workOuts[indexPath.row]
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .MediumStyle
        let time = dateFormatter.stringFromDate(workOut.startDate)
        cell!.textLabel?.text = "Time:" + time
        
        
        //经历时间
        var detailtText = ""
        
        let durationFormatter = NSDateComponentsFormatter()
        let durationTime =  durationFormatter.stringFromTimeInterval(workOut.duration)
        detailtText = "Duration:" + durationTime!
        
        //距离
        let workOutUnit = HKUnit.mileUnit()
        let distance =  workOut.totalDistance?.doubleValueForUnit(workOutUnit)
        detailtText += ", Distance:" + String(distance!)
        
        //消耗能量
        let energyValue =  workOut.totalEnergyBurned?.doubleValueForUnit(HKUnit.calorieUnit())
        detailtText += ", Energy:" + String(energyValue!)
        
        cell?.detailTextLabel?.text = detailtText
        
        return cell!
    }
    
}
