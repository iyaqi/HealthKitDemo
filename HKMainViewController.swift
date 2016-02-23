//
//  HKMainViewController.swift
//  HealthKitDmo
//
//  Created by iyaqi on 16/2/18.
//  Copyright © 2016年 iyaqi. All rights reserved.
//

import UIKit
import HealthKit

class HKMainViewController: UITableViewController {
    
    let kProfileSegueIdentifier = "profileSegue"
    let kWorkoutSegueIdentifier = "workoutsSegue"
    
    let healthManager = HealthManager()
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kProfileSegueIdentifier{
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.healthManager = healthManager
        }else if segue.identifier == kWorkoutSegueIdentifier{
            let workoutsViewController = segue.destinationViewController as! WorkOutsViewController
            workoutsViewController.healthManager = healthManager
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 2:
            authorizeHealthKit()
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func authorizeHealthKit()
    {
        healthManager.authorizeHealthKit { (success, error) -> Void in
            if success{
                print("The device is avaliable!")
            }else{
                print("The device is not avaliable!")
                if error != nil{
                    print("\(error)")
                }
            }
        }
    }
}
