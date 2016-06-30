//
//  ChartPointTextCircleView.swift
//  swift_charts
//
//  Created by ischuetz on 14/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public class ChartPointTextCircleView: UILabel {
   
    private let targetCenter: CGPoint
    public var viewTapped: ((ChartPointTextCircleView) -> ())?
    
    public var selected: Bool = false {
        didSet {
            if self.selected {
                self.textColor = UIColor.whiteColor()
                self.layer.borderColor = UIColor.whiteColor().CGColor
                self.layer.backgroundColor = UIColor.blackColor().CGColor
                
            } else {
                self.textColor = UIColor.blackColor()
                self.layer.borderColor = UIColor.blackColor().CGColor
                self.layer.backgroundColor = UIColor.whiteColor().CGColor
            }
        }
    }
    
    public init(chartPoint: ChartPoint, center: CGPoint, diameter: CGFloat, cornerRadius: CGFloat, borderWidth: CGFloat, font: UIFont) {
        
        self.targetCenter = center
        
        super.init(frame: CGRectMake(0, center.y - diameter / 2, diameter, diameter))

        self.textColor = UIColor.blackColor()
        self.text = chartPoint.description
        self.font = font
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.textAlignment = NSTextAlignment.Center
        self.layer.borderColor = UIColor.grayColor().CGColor
        
        let c = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
        self.layer.backgroundColor = c.CGColor

        self.userInteractionEnabled = true
    }
   
    override public func didMoveToSuperview() {
        
        super.didMoveToSuperview()

    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        viewTapped?(self)
    }
}
