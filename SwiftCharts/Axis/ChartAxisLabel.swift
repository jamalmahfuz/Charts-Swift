//
//  ChartAxisLabel.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A model of an axis label
public class ChartAxisLabel {

    public let text: String
    public let settings: ChartLabelSettings

    var hidden: Bool = false

    /// The size of the bounding rectangle for the axis label, taking into account the font and rotation it will be drawn with
    public lazy var textSize: CGSize = {
        let size = self.text.size(self.settings.font)
        if self.settings.rotation =~ 0 {
            return size
        } else {
            return CGRectMake(0, 0, size.width, size.height).boundingRectAfterRotating(radians: self.settings.rotation * CGFloat(M_PI) / 180.0).size
        }
    }()
    
    public init(text: String, settings: ChartLabelSettings) {
        self.text = text
        self.settings = settings
    }
}
