//
//  SessionChartView.swift
//  SmartLog
//
//  Created by Dmytro Lisitsyn on 6/24/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit
import Charts

final class SessionChartView: UIView {
    
    private enum ChartDataType {
        case accelerometerData
        case hrData
    }
    
    private var chartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        chartView = LineChartView()
        configureLook(chartView: chartView)
        addSubview(chartView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        chartView.frame = bounds
    }
    
    func set(accelerometerData: [AccelerometerData], markers: [Marker]) {
        chartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let weakSelf = self else { return }
            
            let accelerometerData = accelerometerData.sortByDateTaken(.orderedAscending)
            var markers: Set<Marker> = Set(markers)
            
            var xVals: [String?] = []
            var xEntries: [ChartDataEntry] = []
            var yEntries: [ChartDataEntry] = []
            var zEntries: [ChartDataEntry] = []
            var markersChartHightlights: [Highlight] = []
            
            let halfOfMaxItemsCount = 1600 / 2
            let gap = accelerometerData.count > halfOfMaxItemsCount ? accelerometerData.count / halfOfMaxItemsCount : 1
            
            var xIndex = 0
            
            for (index, sample) in accelerometerData.enumerated() {
                let marker = markers.filter({ Int($0.dateAdded.timeIntervalSince1970) == Int(sample.dateTaken.timeIntervalSince1970) }).first
                if let marker = marker {
                    let markerChartHighlight = Highlight(x: 0, y: 0, dataSetIndex: 0)
                    markersChartHightlights.append(markerChartHighlight)
                        
                    markers.remove(marker)
                }
                
                let indexModulo = index % gap
                
                if indexModulo == 0 {
                    xVals.append(nil)
                    
                    let xEntry = ChartDataEntry(x: Double(xIndex), y: Double(sample.x))
                    xEntries.append(xEntry)
                    
                    let yEntry = ChartDataEntry(x: Double(xIndex), y: Double(sample.y))
                    yEntries.append(yEntry)
                    
                    let zEntry = ChartDataEntry(x: Double(xIndex), y: Double(sample.z))
                    zEntries.append(zEntry)
                    
                    xIndex += 1
                }
            }
                        
            let xSet = LineChartDataSet(values: xEntries, label: nil)
            weakSelf.configureLook(dataSet: xSet, dataSetColor: UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8))
            
            let ySet = LineChartDataSet(values: yEntries, label: nil)
            weakSelf.configureLook(dataSet: ySet, dataSetColor: UIColor(red: 0.2, green: 1, blue: 0.2, alpha: 0.8))
            
            let zSet = LineChartDataSet(values: zEntries, label: nil)
            weakSelf.configureLook(dataSet: zSet, dataSetColor: UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 0.8))
            
            let lineChartData = LineChartData(dataSets: [xSet, ySet, zSet])
            
            DispatchQueue.main.async {
                weakSelf.chartView.data = lineChartData
                weakSelf.chartView.highlightValues(markersChartHightlights)
            }
        }
    }
    
    func set(hrData: [HRData], markers: [Marker]) {
        let leftOffset: CGFloat = hrData.isEmpty ? 0 : 40
        chartView.setViewPortOffsets(left: leftOffset, top: 0, right: 0, bottom: 0)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let weakSelf = self else { return }
            
            let hrData = hrData.sortByDateTaken(.orderedAscending)
            var markers: Set<Marker> = Set(markers)
            
            var xVals: [String?] = []
            var hrEntries: [ChartDataEntry] = []
            var markersChartHightlights: [Highlight] = []
            
            let halfOfMaxItemsCount = 1600 / 2
            let gap = hrData.count > halfOfMaxItemsCount ? hrData.count / halfOfMaxItemsCount : 1
            
            var xIndex = 0
            
            for (index, sample) in hrData.enumerated() {
                let marker = markers.filter({ Int($0.dateAdded.timeIntervalSince1970) == Int(sample.dateTaken.timeIntervalSince1970) }).first
                if let marker = marker {
                    let markerChartHighlight = Highlight(x: Double(xIndex), y: 0, dataSetIndex: 0)
                    markersChartHightlights.append(markerChartHighlight)
                    
                    markers.remove(marker)
                }
                
                let indexModulo = index % gap
                
                if indexModulo == 0 {
                    xVals.append(nil)
                    
                    let hrEntry = ChartDataEntry(x: Double(xIndex), y: Double(sample.heartRate))
                    hrEntries.append(hrEntry)

                    xIndex += 1
                }
            }
            
            let hrSet = LineChartDataSet(values: hrEntries, label: nil)
            weakSelf.configureLook(dataSet: hrSet, dataSetColor: UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8))
            
            let lineChartData = LineChartData(dataSets: [hrSet])
            
            DispatchQueue.main.async {
                weakSelf.chartView.data = lineChartData
                weakSelf.chartView.highlightValues(markersChartHightlights)
            }
        }
    }
    
    private func configureLook(chartView: LineChartView) {
        chartView.chartDescription?.text = ""
        chartView.noDataText = "Loading..."
        
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        
        chartView.dragEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.scaleYEnabled = false
        
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        configureLook(visibleAxis: chartView.xAxis)
        configureLook(visibleAxis: chartView.leftAxis)
    }
    
    private func configureLook(visibleAxis: AxisBase) {
        visibleAxis.enabled = true
        visibleAxis.drawLabelsEnabled = true
        visibleAxis.drawGridLinesEnabled = false
        visibleAxis.drawAxisLineEnabled = false
        
        visibleAxis.labelTextColor = .appDarkGrey
    }
    
    private func configureLook(dataSet: LineChartDataSet, dataSetColor: UIColor) {
        dataSet.setColor(dataSetColor)
        
        dataSet.lineWidth = 1
        
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = .appTint
    }
}
