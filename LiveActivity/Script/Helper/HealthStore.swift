//
//  HealthStore.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/04/20.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import HealthKit

typealias RequestCompletion = (Bool, Error?) -> Void
typealias QueryResultsHanlder = (HKSampleQuery, [HKSample]?, Error?) -> Void

class HealthStore {

    static let shared = HealthStore()

    private let healthStore = HKHealthStore()
    private let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    private let readDataTypes: Set<HKObjectType> = [
        HKWorkoutType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]

    func requestAuthorization(completion: @escaping RequestCompletion) {
        healthStore.requestAuthorization(toShare: nil, read: readDataTypes, completion: completion)
    }

    func queryExecute(sampleType: HKSampleType, predicate: NSPredicate?, resultsHanlder: @escaping QueryResultsHanlder) {
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor], resultsHandler: resultsHanlder)
        healthStore.execute(query)
    }
}
