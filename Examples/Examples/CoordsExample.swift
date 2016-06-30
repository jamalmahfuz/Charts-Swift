//
//  CoordsExample.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import SwiftCharts

class CoordsExample: UIViewController {
    
    private var chart: Chart? // arc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints = [(2, 2), (3, 1), (5, 9), (6, 7), (8, 10), (9, 9), (10, 15), (13, 8), (15, 20), (16, 17)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let xValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 7, maxSegmentCount: 7, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: true)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        chartSettings.trailing = 20
        chartSettings.labelsToAxisSpacingX = 15
        chartSettings.labelsToAxisSpacingY = 15
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let showCoordsTextViewsGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart, isTransform: Bool) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            let w: CGFloat = 70
            let h: CGFloat = 30
            
            let text = "(\(chartPoint.x), \(chartPoint.y))"
            let font = ExamplesDefaults.labelFont
            let textSize = ChartUtils.textSize(text, font: font)
            let x = min(screenLoc.x + 5, chart.bounds.width - textSize.width - 5)
            let view = UIView(frame: CGRectMake(x, screenLoc.y - h, w, h))
            let label = UILabel(frame: view.bounds)
            label.text = "(\(chartPoint.x), \(chartPoint.y))"
            label.font = ExamplesDefaults.labelFont
            view.addSubview(label)
            view.alpha = 0
            
            func targetState() {
                view.alpha = 1
            }
            if isTransform {
                targetState()
            } else {
                UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
                    targetState()
                }, completion: nil)
            }
            
            return view
        }
        
        let showCoordsLinesLayer = ChartShowCoordsLinesLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: chartPoints)
        let showCoordsTextLayer = ChartPointsSingleViewLayer<ChartPoint, UIView>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: showCoordsTextViewsGenerator)
        
        let touchViewsGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart, isTransform: Bool) -> UIView? in
            let (chartPoint, screenLoc) = (chartPointModel.chartPoint, chartPointModel.screenLoc)
            let s: CGFloat = 30
            let view = HandlingView(frame: CGRectMake(screenLoc.x - s/2, screenLoc.y - s/2, s, s))
            view.touchHandler = {[weak showCoordsLinesLayer, weak showCoordsTextLayer, weak chartPoint, weak chart] in
                guard let chartPoint = chartPoint, chart = chart else {return}
                showCoordsLinesLayer?.showChartPointLines(chartPoint, chart: chart)
                showCoordsTextLayer?.showView(chartPoint: chartPoint, chart: chart)
            }
            return view
        }
        
        let touchLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: touchViewsGenerator)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor(red: 0.4, green: 0.4, blue: 1, alpha: 0.2), lineWidth: 3, animDuration: 0.7, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart, isTransform: Bool) -> UIView? in
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 24)
            circleView.animDuration = isTransform ? 0 : 1.5
            circleView.fillColor = UIColor.whiteColor()
            circleView.borderWidth = 5
            circleView.borderColor = UIColor.blueColor()
            return circleView
        }
        let chartPointsCircleLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: circleViewGenerator, displayDelay: 0, delayBetweenItems: 0.05)
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, innerFrame: innerFrame, settings: settings)
        
        
        let chart = Chart(
            frame: chartFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                showCoordsLinesLayer,
                chartPointsLineLayer,
                chartPointsCircleLayer,
                showCoordsTextLayer,
                touchLayer,
                
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
    }
    
}
