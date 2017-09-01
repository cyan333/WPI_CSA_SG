//
//  ColoredView.swift
//  WPI_CSA
//
//  Created by NingFangming on 8/30/17.
//  Copyright © 2017 fangming. All rights reserved.
//

import UIKit

class ColoredView: UIView {
    var viewFrame: CGRect
    
    override init(frame: CGRect) {
        viewFrame = frame
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewFrame = CGRect()
        super.init(coder: aDecoder)
    }
    
    func setTopHalfColor(color: UIColor) {
        setViewGradient(colors: [color.cgColor, color.cgColor, UIColor.white.cgColor, UIColor.white.cgColor],
                        locations: [0.0, 0.45, 0.55, 1.0])
    }
    
    func setVerticalGradient(topColor: UIColor, bottomColor: UIColor) {
        setViewGradient(colors: [topColor.cgColor, bottomColor.cgColor],
                        locations: [0.0,1.0])
    }
    
    func removeColorLayer() {
        if let layer = self.layer.sublayers?.first {
            layer.removeFromSuperlayer()
        }
    }
    
    func setViewGradient(colors: [CGColor], locations: [Double]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations as [NSNumber]
        gradientLayer.frame = viewFrame
        
        removeColorLayer()
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
}
