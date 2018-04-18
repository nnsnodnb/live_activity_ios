//
//  ViewController.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/04/17.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    private let healthStore = HKHealthStore()
    let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
    ]

    private var workouts = [HKWorkout]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    private func requestAuthorization() {
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { [unowned self] (success, error) in
            guard success, error == nil else {
                return
            }
            self.getWorkouts()
        }
    }

    private func getWorkouts() {
        let predicate =  HKQuery.predicateForWorkouts(with: .other)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                return
            }
            self.workouts = workouts
        }
        healthStore.execute(sampleQuery)
    }
}
