//
//  DetailViewController.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/05/03.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import Charts
import HealthKit
import SVProgressHUD

class DetailViewController: UIViewController {

    enum HeartRateType {
        case minimum
        case maximum
        case average
    }

    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityTimeLabel: UILabel!
    @IBOutlet weak var activityPlayTimeLabel: UILabel!
    @IBOutlet weak var activeCalorieLabel: UILabel!
    @IBOutlet weak var minHeartRateLabel: UILabel!
    @IBOutlet weak var maxHeartRateLabel: UILabel!
    @IBOutlet weak var averateHeartRateLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var miniHeartRateButton: UIButton!
    @IBOutlet weak var maxHeartRateButton: UIButton!
    @IBOutlet weak var averageHeartRateButton: UIButton!

    var workout: HKWorkout!
    var statistic: HKStatistics!

    private var statistics = [HKStatistics]()
    private var heartRateType: HeartRateType = .average {
        didSet {
            setDataSet()
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        setupLabels()
        getHeartRates()
        chartView.isHidden = true
        setupChartView()
        averageHeartRateButton.backgroundColor = UIColor.mainYellow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    private func setupTitle() {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: workout.startDate)
        let weekdaySymbolIndex = component - 1
        let formatter: DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        title = "\(DateFormatter.title.string(from: workout.startDate))(\(formatter.shortWeekdaySymbols[weekdaySymbolIndex]))"
    }

    private func setupLabels() {
        let dateKey = DateFormatter.standard.string(from: workout.startDate)
        if let name = UserDefaults.standard.string(forKey: dateKey), name != "" {
            activityNameLabel.text = name
        } else {
            activityNameLabel.text = "不明な推し事"
        }

        let startDateString = DateFormatter.withOutDate.string(from: workout.startDate)
        let endDateString = DateFormatter.withOutDate.string(from: workout.endDate)
        activityTimeLabel.text = "\(startDateString) 〜 \(endDateString)"

        activityPlayTimeLabel.text = "\(workout.duration.convertToDateTime(format: "%d時間%0.2d分%0.2d秒"))"

        activeCalorieLabel.text = String(format: "%.2f カロリー", workout.totalEnergyBurned?.doubleValue(for: HealthStore.energyUnit) ?? 0)

        minHeartRateLabel.text = String(format: "%.0fBPM", statistic.minimumQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0)
        maxHeartRateLabel.text = String(format: "%.0fBPM", statistic.maximumQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0)
        averateHeartRateLabel.text = String(format: "%.2fBPM", statistic.averageQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0)
    }

    private func getHeartRates() {
        SVProgressHUD.show()
        var dateComponents = DateComponents()
        dateComponents.minute = 5
        let collectionQuery = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .heartRate)!, quantitySamplePredicate: nil, options: [.discreteAverage, .discreteMin, .discreteMax], anchorDate: workout.startDate, intervalComponents: dateComponents)
        collectionQuery.initialResultsHandler = { [weak self] (query, result, error) in
            guard let wself = self, let result = result, error == nil else { return }
            result.enumerateStatistics(from: wself.workout.startDate, to: wself.workout.endDate) { (statistic, stop) in
                wself.statistics.append(statistic)
                wself.setDataSet()
            }
        }
        HealthStore.shared.execute(query: collectionQuery)
    }

    private func setupChartView() {
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false

        let llXAxis = ChartLimitLine(limit: 0)
        llXAxis.lineWidth = 4
        llXAxis.lineDashLengths = [10, 10, 0]
        llXAxis.valueFont = .systemFont(ofSize: 10)

        chartView.xAxis.gridLineDashLengths = [10, 10]
        chartView.xAxis.gridLineDashPhase = 0

        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.axisMaximum = (statistic.maximumQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0) + 10
        var minimum = (statistic.minimumQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0)
        if minimum != 0 {
            minimum -= 10
        }
        chartView.leftAxis.axisMinimum = minimum
        chartView.leftAxis.gridLineDashLengths = [5, 5]
        chartView.leftAxis.drawLimitLinesBehindDataEnabled = true

        chartView.rightAxis.enabled = false

        let marker = BalloonMarker(color: UIColor(white: 180 / 255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker

        chartView.legend.form = .line

        chartView.animate(xAxisDuration: 2.0)
    }

    private func setDataSet() {
        // nilのものを予め削除しておく
        let statistics = self.statistics.filter { $0.averageQuantity() != nil }
        let values: [ChartDataEntry] = (0..<statistics.count).map {
            let quantity: HKQuantity?
            switch heartRateType {
            case .minimum:
                quantity = statistics[$0].minimumQuantity()
            case .maximum:
                quantity = statistics[$0].maximumQuantity()
            case .average:
                quantity = statistics[$0].averageQuantity()
            }
            let value = quantity?.doubleValue(for: HealthStore.bpmUnit) ?? 0
            return ChartDataEntry(x: Double($0), y: Double(String(format: "%.2f", value))!)
        }

        let set = LineChartDataSet(values: values, label: "心拍数(5分毎の平均)")
        set.drawIconsEnabled = false
        set.lineDashLengths = [5, 2.5]
        set.highlightLineDashLengths = [5, 2.5]
        set.setColor(.black)
        set.setCircleColor(.black)
        set.lineWidth = 1
        set.circleRadius = 3
        set.drawCircleHoleEnabled = false
        set.valueFont = .systemFont(ofSize: 9)
        set.formLineDashLengths = [5, 2.5]
        set.formLineWidth = 1
        set.formSize = 15

        let gradientColors: [CGColor] = [UIColor.white.cgColor, UIColor.red.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        set.fillAlpha = 1
        // グラデーションの角度
        set.fill = Fill(linearGradient: gradient, angle: 90)
        set.drawFilledEnabled = true

        let data = LineChartData(dataSet: set)

        DispatchQueue.main.async {
            self.chartView.isHidden = false
            SVProgressHUD.dismiss()
            self.chartView.data = data
        }
    }

    // MARK: - IBAction

    @IBAction func onTapMiniHeartRateButton(_ sender: Any) {
        heartRateType = .minimum
        miniHeartRateButton.backgroundColor = UIColor.mainYellow
        maxHeartRateButton.backgroundColor = UIColor.mainOrange
        averageHeartRateButton.backgroundColor = UIColor.mainOrange
    }

    @IBAction func onTapMaxHeartRateButton(_ sender: Any) {
        heartRateType = .maximum
        miniHeartRateButton.backgroundColor = UIColor.mainOrange
        maxHeartRateButton.backgroundColor = UIColor.mainYellow
        averageHeartRateButton.backgroundColor = UIColor.mainOrange
    }

    @IBAction func onTapAverageHeartRateButton(_ sender: Any) {
        heartRateType = .average
        miniHeartRateButton.backgroundColor = UIColor.mainOrange
        maxHeartRateButton.backgroundColor = UIColor.mainOrange
        averageHeartRateButton.backgroundColor = UIColor.mainYellow
    }
}

// MARK: - ChartViewDelegate

extension DetailViewController: ChartViewDelegate {

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(#function)
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print(#function)
    }

    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        print(#function)
    }

    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        print(#function)
    }
}
