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
    private let unit = HKUnit.degreeCelsius()
    private let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    private let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
    ]

    private var workouts = [HKWorkout]()
    private var bodyTemperatures = [Double]()

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
        let predicate = HKQuery.predicateForWorkouts(with: .other)
        let type = HKWorkoutType.workoutType()
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            guard let wself = self, let workouts = samples as? [HKWorkout], error == nil else { return }
            wself.workouts = workouts
        }
        healthStore.execute(query)
    }

    private func getBodyTemperatures() {
        guard let type = HKObjectType.quantityType(forIdentifier: .bodyTemperature) else { return }
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 0, sortDescriptors: [sortDescriptor]) { [weak self] (query, samples, error) in
            guard let wself = self, let bodyTemperatures = samples as? [HKQuantitySample], error == nil else { return }
            wself.bodyTemperatures = bodyTemperatures.map { $0.quantity.doubleValue(for: wself.unit) }
        }
        healthStore.execute(query)
    }
}
