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

class DetailViewController: UIViewController {

    @IBOutlet weak var chartView: LineChartView!

    var workout: HKWorkout!

    private var statistics = [HKStatistics]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getHeartRates()
        setupChartView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    private func getHeartRates() {
        var dateComponents = DateComponents()
        dateComponents.minute = 5
        let collectionQuery = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .heartRate)!, quantitySamplePredicate: nil, options: [.discreteAverage], anchorDate: workout.startDate, intervalComponents: dateComponents)
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
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true

        let llXAxis = ChartLimitLine(limit: 0)
        llXAxis.lineWidth = 4
        llXAxis.lineDashLengths = [10, 10, 0]
        llXAxis.valueFont = .systemFont(ofSize: 10)

        chartView.xAxis.gridLineDashLengths = [10, 10]
        chartView.xAxis.gridLineDashPhase = 0

        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.axisMaximum = 250
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true

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
        let values: [ChartDataEntry] = (0..<statistics.count).map {
            let value = statistics[$0].averageQuantity()?.doubleValue(for: HealthStore.bpmUnit) ?? 0
            return ChartDataEntry(x: Double($0), y: value)
        }

        let set = LineChartDataSet(values: values, label: "Heart Rate")
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
            self.chartView.data = data
        }
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
