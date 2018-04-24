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

    @IBOutlet weak var tableView: UITableView!

    private var workouts = [HKWorkout]()
    private var bodyTemperatures = [Double]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        requestAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "WorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkoutTableViewCell")
        tableView.rowHeight = 80
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }

    private func requestAuthorization() {
        HealthStore.shared.requestAuthorization { [unowned self] (success, error) in
            guard success, error == nil else { return }
            self.getWorkouts()
        }
    }

    private func getWorkouts() {
        let type = HKWorkoutType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .other)
        HealthStore.shared.queryExecute(sampleType: type, predicate: predicate) { [weak self] (query, samples, error) in
            guard let wself = self, let workouts = samples as? [HKWorkout], error == nil else { return }
            wself.workouts = workouts
            DispatchQueue.main.async {
                wself.tableView.reloadData()
            }
        }
    }

    private func getBodyTemperatures() {
        guard let type = HKObjectType.quantityType(forIdentifier: .bodyTemperature) else { return }
        HealthStore.shared.queryExecute(sampleType: type, predicate: nil) { [weak self] (query, samples, error) in
            guard let wself = self, let bodyTemperatures = samples as? [HKQuantitySample], error == nil else { return }
            wself.bodyTemperatures = bodyTemperatures.map { $0.quantity.doubleValue(for: Constants.degreeUnit) }
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutTableViewCell", for: indexPath) as! WorkoutTableViewCell
        cell.setConfigure(workouts[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
