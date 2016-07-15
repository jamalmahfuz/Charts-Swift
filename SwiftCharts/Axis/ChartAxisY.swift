//
//  ChartAxisY.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartAxisY: ChartAxis {
    
    public override var length: Double {
        return last - first
    }
    
    public override var screenLength: CGFloat {
        return firstScreen - lastScreen
    }
    
    public override var visibleLength: Double {
        return lastVisible - firstVisible
    }
    
    public override var visibleScreenLength: CGFloat {
        return firstVisibleScreen - lastVisibleScreen
    }
    
    public override func screenLocForScalar(scalar: Double) -> CGFloat {
        return firstScreen - internalScreenLocForScalar(scalar)
    }
    
    public override func innerScreenLocForScalar(scalar: Double) -> CGFloat {
        return screenLength - internalScreenLocForScalar(scalar)
    }
    
    public override func scalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return (Double(-(screenLoc - firstScreen)) * length / Double(screenLength)) + first
    }
    
    public override func innerScalarForScreenLoc(screenLoc: CGFloat) -> Double {
        return length + (Double(-(screenLoc)) * length / Double(screenLength)) + first
    }
    
    
    override func zoom(x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        
        // Zoom around center of gesture. Uses center as anchor point dividing the line in 2 segments which are scaled proportionally.
        let segment1 = firstScreen - centerY
        let segment2 = centerY - lastScreen
        let deltaSegment1 = (segment1 * y) - segment1
        let deltaSegment2 = (segment2 * y) - segment2
        var newOriginY = firstScreen + deltaSegment1
        var newEndY = lastScreen - deltaSegment2
        
        if newEndY > lastScreenInit {
            let delta = newEndY - lastScreenInit
            newEndY = lastScreenInit
            newOriginY = newOriginY - delta
        }
        
        if newOriginY < firstScreenInit {
            let delta = firstScreenInit - newOriginY
            newOriginY = firstScreenInit
            newEndY = newEndY + delta
        }
        
        if newOriginY - newEndY > firstScreenInit - lastScreenInit { // new length > original length
            firstScreen = newOriginY
            lastScreen = newEndY
            
            // if new origin is above origin, move it back
            let offsetOriginY = firstScreenInit - firstScreen
            if offsetOriginY > 0 {
                firstScreen = firstScreen + offsetOriginY
                lastScreen = lastScreen + offsetOriginY
            }
            
        } else { // possible correction
            firstScreen = firstScreenInit
            lastScreen = lastScreenInit
        }
    }
    
    
    override func pan(deltaX: CGFloat, deltaY: CGFloat) {
        
        let length = screenLength
        
        let (newOriginY, newEndY): (CGFloat, CGFloat) = {
            
            if deltaY < 0 { // scrolls up
                let originY = max(firstScreenInit, firstScreen + deltaY)
                let endY = originY - length
                return (originY, endY)
                
            } else if deltaY > 0 { // scrolls down
                let endY = min(lastScreenInit, lastScreen + deltaY)
                let originY = endY + length
                return (originY, endY)
                
            } else {
                return (firstScreen, lastScreen)
            }
        }()
        
        firstScreen = newOriginY
        lastScreen = newEndY
    }
    
    override func zoom(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        zoom(scaleX, y: scaleY / CGFloat(zoomFactor), centerX: centerX, centerY: centerY)
    }
}