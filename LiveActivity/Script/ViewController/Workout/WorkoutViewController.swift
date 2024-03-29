//
//  WorkoutViewController.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/04/17.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import HealthKit
import SVProgressHUD

class WorkoutViewController: UITableViewController {

    private var workouts = [HKWorkout]()
    private var statistics = [HKStatistics]()
    private var bodyTemperatures = [Double]()
    private var selectWorkout: HKWorkout?

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
        tableView.rowHeight = 183
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
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        let type = HKWorkoutType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .other)
        HealthStore.shared.queryExecute(sampleType: type, predicate: predicate) { [weak self] (query, samples, error) in
            guard let wself = self, let workouts = samples as? [HKWorkout], error == nil else { return }
            wself.workouts = workouts
            wself.workouts.forEach { wself.getHeartRates(workout: $0) }
            DispatchQueue.main.async {
                wself.tableView.reloadData()
                SVProgressHUD.dismiss(withDelay: 0.5)
            }
        }
    }

    private func getHeartRates(workout: HKWorkout) {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.discreteAverage, .discreteMin, .discreteMax]) { [weak self] (query, statistic, error) in
            guard let wself = self, let statistic = statistic, error == nil else { return }
            wself.statistics.append(statistic)
            print(DateFormatter.debug.string(from: statistic.startDate))
            print("最低値 \(statistic.minimumQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0) bpm")
            print("最高値 \(statistic.maximumQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0) bpm")
            print("平均値 \(statistic.averageQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0) bpm")
        }
        HealthStore.shared.execute(query: query)
    }

    private func showUpdateActivityNameAlert(with workout: HKWorkout) {
        selectWorkout = workout
        let alert = UIAlertController(title: "タイトルを入力", message: nil, preferredStyle: .alert)
        alert.addTextField { [unowned self] (textField) in
            let dateKey = DateFormatter.standard.string(from: workout.startDate)
            textField.text = UserDefaults.standard.string(forKey: dateKey)
            textField.delegate = self
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - IBAction

    @IBAction func onTapRefreshButton(_ sender: Any) {
        getWorkouts()
    }
}

// MARK: - UITableViewDataSource

extension WorkoutViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutTableViewCell", for: indexPath) as! WorkoutTableViewCell
        cell.setConfigure(workouts[indexPath.row])
        cell.updateActivityNameHandler = { [unowned self] in
            self.showUpdateActivityNameAlert(with: $0)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WorkoutViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewController = DetailViewController()
        detailViewController.workout = workouts[indexPath.row]
        detailViewController.statistic = statistics[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension WorkoutViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let workout = selectWorkout else { return }
        let dateKey = DateFormatter.standard.string(from: workout.startDate)
        UserDefaults.standard.set(textField.text, forKey: dateKey)
        UserDefaults.standard.synchronize()
        selectWorkout = nil
    }
}
