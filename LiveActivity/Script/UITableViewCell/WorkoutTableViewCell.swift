//
//  WorkoutTableViewCell.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/04/21.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var eventStartLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var caloryLabel: UILabel!

    var workout: HKWorkout!
    var updateActivityNameHandler: ((HKWorkout) -> Void)?

    // MARK: - Life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Public method

    func setConfigure(_ workout: HKWorkout) {
        self.workout = workout
        datetimeLabel.text = "\(workout.duration.convertToDateTime(format: "%d時間%0.2d分%0.2d秒"))"
        caloryLabel.text = String(format: "%.2f Cal.", workout.totalEnergyBurned?.doubleValue(for: HealthStore.energyUnit) ?? 0)
        guard let workoutEvents = workout.workoutEvents, let event = workoutEvents.first else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = " yyyy年MM月dd日 "
        eventStartLabel.text = formatter.string(from: event.date)
    }

    // MARK: - IBAction

    @IBAction func onTapUpdateActivityNameButton(_ sender: Any) {
        updateActivityNameHandler?(workout)
    }
}
