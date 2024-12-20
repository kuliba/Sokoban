//
//  SliderView.swift
//
//
//  Created by Valentin Ozerov on 10.12.2024.
//

import UIKit
import SwiftUI

struct SliderView: UIViewRepresentable {
    
    final class Coordinator: NSObject {
        
        var value: Binding<Double>
        
        init(value: Binding<Double>) {
            
            self.value = value
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            
            self.value.wrappedValue = Double(sender.value)
        }
    }
    
    @Binding var value: Double
    
    var maximumValue: Float
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    var thumbDiameter: CGFloat
    var trackHeight: CGFloat
    
    func makeUIView(context: Context) -> UISlider {
        
        let slider = CalculatorSlider(frame: .zero, trackHeight: 2)
        slider.maximumValue = maximumValue
        slider.setThumbImage(.circle(diameter: thumbDiameter, color: .clear), for: .normal)
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.value = Float(value)
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        
        uiView.value = Float(self.value)
    }
    
    func makeCoordinator() -> SliderView.Coordinator {
        
        Coordinator(value: $value)
    }
}

final class CalculatorSlider: UISlider {
    
    var trackHeight: CGFloat
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    init(frame: CGRect, trackHeight: CGFloat) {
        
        self.trackHeight = trackHeight
        super.init(frame: frame)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = trackHeight
        return result
    }
}

extension UIImage {
    
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        
        let lineWidth: CGFloat = 2
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: diameter + lineWidth, height: diameter + lineWidth),
            false,
            0
        )
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        ctx.setStrokeColor(UIColor.red.cgColor)
        
        let rect = CGRect(
            x: lineWidth / 2,
            y: lineWidth / 2,
            width: diameter,
            height: diameter
        )
        let circle = UIBezierPath(ovalIn: rect)
        
        circle.fill()
        
        circle.lineWidth = lineWidth
        circle.stroke()
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
