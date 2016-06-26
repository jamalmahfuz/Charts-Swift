//
//  ChartAxisY.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisY: ChartAxis {
    
    public override var length: CGFloat {
        return firstScreen - lastScreen
    }
    
    public override var modelLength: Double {
        return last - first
    }
    
    public override func screenLocForScalar(scalar: Double) -> CGFloat {
        return firstScreen - innerScreenLocForScalar(scalar)
    }
    
    public override func scalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return (Double(-(screenLoc - firstScreen)) * modelLength / Double(length)) + first
    }
}