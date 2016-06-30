//
//  BarsPlusMinusAndLinesExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class BarsPlusMinusAndLinesExample: UIViewController {

    private var chart: Chart? // arc

    override func viewDidLoad() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let barsData: [(title: String, min: Double, max: Double)] = [
            ("A", -65, 40),
            ("B", -30, 50),
            ("C", -40, 35),
            ("D", -50, 40),
            ("E", -60, 30),
            ("F", -35, 47),
            ("G", -30, 60),
            ("H", -46, 48)
        ]

        let lineData: [(title: String, val: Double)] = [
            ("A", -10),
            ("B", 20),
            ("C", -20),
            ("D", 10),
            ("E", -20),
            ("F", 23),
            ("G", 10),
            ("H", 45)
        ]
        
        let alpha: CGFloat = 0.5
        let posColor = UIColor.greenColor().colorWithAlphaComponent(alpha)
        let negColor = UIColor.redColor().colorWithAlphaComponent(alpha)
        let zero = ChartAxisValueDouble(0)
        let bars: [ChartBarModel] = barsData.enumerate().flatMap {index, tuple in
            [
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.min), bgColor: negColor),
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.max), bgColor: posColor)
            ]
        }
        
        let yValues = (-80).stride(through: 80, by: 20).map {ChartAxisValueDouble(Double($0), labelSettings: labelSettings)}
        let xValues =
            [ChartAxisValueString(order: -1)] +
            barsData.enumerate().map {index, tuple in ChartAxisValueString(tuple.0, order: index, labelSettings: labelSettings)} +
            [ChartAxisValueString(order: barsData.count)]

        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let barsLayer = ChartBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, bars: bars, horizontal: false, barWidth: Env.iPad ? 40 : 25, animDuration: 0.5)
        
        // labels layer
        // create chartpoints for the top and bottom of the bars, where we will show the labels
        let labelChartPoints = bars.map {bar in
            ChartPoint(x: bar.constant, y: bar.axisValue2)
        }
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let labelsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: labelChartPoints, viewGenerator: {(chartPointModel, layer, chart, isTransform) -> UIView? in
            let label = HandlingLabel()
            let posOffset: CGFloat = 10
            
            let pos = chartPointModel.chartPoint.y.scalar > 0
            
            let yOffset = pos ? -posOffset : posOffset
            label.text = "\(formatter.stringFromNumber(chartPointModel.chartPoint.y.scalar)!)%"
            label.font = ExamplesDefaults.labelFont
            label.sizeToFit()
            label.center = CGPointMake(chartPointModel.screenLoc.x, pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0

            label.movedToSuperViewHandler = {[weak label] in
                
                func targetState() {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y + yOffset
                }
                
                if isTransform {
                    targetState()
                } else {
                    UIView.animateWithDuration(0.3, animations: {
                        targetState()
                    })
                }
            }
            return label
            
        }, displayDelay: 0.5) // show after bars animation
        
        // line layer
        let lineChartPoints = lineData.enumerate().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.val))}
        let lineModel = ChartLineModel(chartPoints: lineChartPoints, lineColor: UIColor.blackColor(), lineWidth: 2, animDuration: 0.5, animDelay: 1)
        let lineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart, isTransform: Bool) -> UIView? in
            let color = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 6)
            circleView.animDuration = isTransform ? 0 : 0.5
            circleView.fillColor = color
            return circleView
        }
        let lineCirclesLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: lineChartPoints, viewGenerator: circleViewGenerator, displayDelay: 1.5, delayBetweenItems: 0.05)
        
        
        // show a gap between positive and negative bar
        let dummyZeroYChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let yZeroGapLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: [dummyZeroYChartPoint], viewGenerator: {(chartPointModel, layer, chart, isTransform) -> UIView? in
            let height: CGFloat = 2
            let v = UIView(frame: CGRectMake(innerFrame.origin.x + 2, chartPointModel.screenLoc.y - height / 2, innerFrame.origin.x + innerFrame.size.height, height))
            v.backgroundColor = UIColor.whiteColor()
            return v
        })
        
        let chart = Chart(
            frame: chartFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                barsLayer,
                labelsLayer,
                yZeroGapLayer,
                lineLayer,
                lineCirclesLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }

}
