//
//  SessionChartView.swift
//  SmartHeartTraining
//
//  Created by Dmytro Lisitsyn on 6/24/16.
//  Copyright © 2016 MadAppGang. All rights reserved.
//

import UIKit
import Charts

final class SessionChartView: UIView {
    
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
    
    func set(accelerometerData accelerometerData: [AccelerometerData], markers: [Marker]) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            guard let weakSelf = self else { return }
            
            let accelerometerData = accelerometerData.sortByDateTaken(.OrderedAscending)
            var markers: Set<Marker> = Set(markers)
            
            var xVals: [String?] = []
            var xEntries: [ChartDataEntry] = []
            var yEntries: [ChartDataEntry] = []
            var zEntries: [ChartDataEntry] = []
            var markersChartHightlights: [ChartHighlight] = []
            
            for (index, accelerometerDataSample) in accelerometerData.enumerate() {
                xVals.append(nil)
                
                let xEntry = ChartDataEntry(value: Double(accelerometerDataSample.x), xIndex: index)
                xEntries.append(xEntry)
                
                let yEntry = ChartDataEntry(value: Double(accelerometerDataSample.y), xIndex: index)
                yEntries.append(yEntry)
                
                let zEntry = ChartDataEntry(value: Double(accelerometerDataSample.z), xIndex: index)
                zEntries.append(zEntry)

                // Because markers can be added with second precision only
                if accelerometerDataSample.dateTaken.timeIntervalSince1970 % 1 == 0 {
                    
                    if let marker = markers.filter({ $0.dateAdded == accelerometerDataSample.dateTaken }).first {
                        let markerChartHighlight = ChartHighlight(xIndex: index, dataSetIndex: 0)
                        markersChartHightlights.append(markerChartHighlight)
                        
                        markers.remove(marker)
                    }
                }
            }
            
            let xSet = LineChartDataSet(yVals: xEntries, label: nil)
            weakSelf.configureLook(dataSet: xSet, dataSetColor: UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8))
            
            let ySet = LineChartDataSet(yVals: yEntries, label: nil)
            weakSelf.configureLook(dataSet: ySet, dataSetColor: UIColor(red: 0.2, green: 1, blue: 0.2, alpha: 0.8))
            
            let zSet = LineChartDataSet(yVals: zEntries, label: nil)
            weakSelf.configureLook(dataSet: zSet, dataSetColor: UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 0.8))
            
            let lineChartData = LineChartData(xVals: xVals, dataSets: [xSet, ySet, zSet])
            
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf.chartView.data = lineChartData
                weakSelf.chartView.highlightValues(markersChartHightlights)
            }
        }
    }
    
    private func configureLook(chartView chartView: LineChartView) {
        chartView.descriptionText = ""
        chartView.noDataText = "Loading..."
        chartView.infoTextColor = UIColor(white: 0.2, alpha: 1)
        
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        
        chartView.dragEnabled = true
        chartView.doubleTapToZoomEnabled = false
        chartView.scaleYEnabled = false
        
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        chartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
        
        configureLook(visibleAxis: chartView.xAxis)
        configureLook(visibleAxis: chartView.leftAxis)
    }
    
    private func configureLook(visibleAxis visibleAxis: ChartAxisBase) {
        visibleAxis.enabled = false
        visibleAxis.drawLabelsEnabled = false
        visibleAxis.drawAxisLineEnabled = false
    }
    
    private func configureLook(dataSet dataSet: LineChartDataSet, dataSetColor: UIColor) {
        dataSet.setColor(dataSetColor)
        
        dataSet.lineWidth = 1
        
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.highlightColor = UIColor.appTint()
    }
}
