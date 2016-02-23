//
//  HealthManager.swift
//  HealthKitDmo
//
//  Created by iyaqi on 16/2/18.
//  Copyright © 2016年 iyaqi. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager {
    
    let hkHealthStore = HKHealthStore()
    
    /**
     
     与健康进行认证
     
     - parameter completion: 参数为一个返回值可为空的函数
     */
    func authorizeHealthKit(completion:((success:Bool,error:NSError!)->Void)!){
        
        //要读的数据
        let healthKitTypesToRead = NSSet(array:[
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
            HKObjectType.characteristicTypeForIdentifier( HKCharacteristicTypeIdentifierBiologicalSex)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
            HKObjectType.characteristicTypeForIdentifier( HKCharacteristicTypeIdentifierFitzpatrickSkinType)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,HKQuantityType.workoutType()
            ])
        
        //要写的数据
        let healthKitTypesToWrite = NSSet(array:[
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
            HKQuantityType.workoutType()
            ])
        
        
        
        
        
        //判断当前设备是否支持
        if !HKHealthStore.isHealthDataAvailable(){
            let error = NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if completion != nil {
                completion(success: false, error: error)
            }
            
            return
        }
        
        //请求连接
        hkHealthStore.requestAuthorizationToShareTypes(healthKitTypesToWrite as? Set<HKSampleType>, readTypes: healthKitTypesToRead as? Set<HKObjectType>) { (success, error) -> Void in
            
            if completion != nil{
                completion(success:success,error:error)
            }
        }
    }
    
    /**
     *  获取个人信息
     没有参数，返回值为元组
     */
    
    func readProfile()->(age:Int?,biologicalsex:HKBiologicalSexObject?,bloodType:HKBloodTypeObject?){
        
        //请求年龄
        var age:Int?
        let birthDay:NSDate;
        do {
            birthDay = try hkHealthStore.dateOfBirth()
            let today = NSDate()
            let diff = NSCalendar.currentCalendar().components(.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions(rawValue: 0))
            age = diff.year
        }catch {
            
        }
        
        //请求性别
        var biologicalSex
        :HKBiologicalSexObject?
        do {
            biologicalSex  = try hkHealthStore.biologicalSex()
            
        }catch {
            
        }
        
        //请求血型
        var hkbloodType:HKBloodTypeObject?
        
        do {
            hkbloodType = try hkHealthStore.bloodType()
        }catch{
            
        }
        
        return (age,biologicalSex,hkbloodType)
    }
    
    
    /**
     *  获取身高和体重
     */
    
    func fetchMostRecentSample(sample:HKSampleType,competion:((HKSample!,NSError!)->Void)!){
        
        //1.创建谓词
        let past = NSDate.distantPast()
        let now = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate: now, options: .None)
        
        //2.创建返回结果排序的描述，是降序还是升序的，因为只需要一个结果，就设定限制为1个
        let sortDescrptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate , ascending: false)
        let limit = 1
        
        //3.创建HKSampleQuery对象，
        let sampleQuery = HKSampleQuery(sampleType: sample, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescrptor]) { (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                competion(nil,queryError)
                return
            }
            
            let mostRecentSample = results?.first
            
            if competion != nil{
                competion(mostRecentSample,nil)
            }
            
        }
        
        //4.执行查询
        self.hkHealthStore.executeQuery(sampleQuery)
    }
    
    /**
     获取workoutData
     */
    func fetchWorkOutsData(completion:([AnyObject]!,NSError!)->Void){
        
        let workOutsSampleType = HKSampleType.workoutType()
        
        let workOutsPredicate = HKQuery.predicateForWorkoutsWithWorkoutActivityType(.Running)
        
        let sortDescrptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate , ascending: false)
        
        let workOutsQuery = HKSampleQuery(sampleType: workOutsSampleType, predicate: workOutsPredicate, limit: 0, sortDescriptors: [sortDescrptor]) { (workoutsQuery, results, error) -> Void in
            
            if (error != nil){
                print("获取失败")
                return
            }
            
            if results != nil{
                completion(results!,nil)
            }
            
        }
        
        self.hkHealthStore.executeQuery(workOutsQuery)
        
    }
    
    
}
