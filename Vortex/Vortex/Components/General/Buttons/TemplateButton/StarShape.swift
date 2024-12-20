//
//  StarView.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 30.05.2023.
//

import Foundation
import SwiftUI

struct StarShape: Shape {
    
    let corners: Int
    let smoothness: Double

    func path(in rect: CGRect) -> Path {
        
        guard corners >= 2 else { return Path() }

        let center = CGPoint(x: rect.midX, y: rect.midY)

        var currentAngle = -CGFloat.pi / 2

        let angleAdjustment = .pi * 2 / Double(corners * 2)

        let innerX = center.x * smoothness
        let innerY = center.y * smoothness

        var path = Path()

        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))

        var bottomEdge: Double = 0

        for corner in 0..<corners * 3  {
            
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let x = corner.isMultiple(of: 2) ? center.x : innerX
            let y = corner.isMultiple(of: 2) ? center.y : innerY
            let bottom: Double

            bottom = corner.isMultiple(of: 2) ? (center.y * sinAngle) : (innerY * sinAngle)
            let point = CGPoint(x: x * cosAngle, y: y * sinAngle)
            path.addLine(to: point)

            if bottom > bottomEdge {
                bottomEdge = bottom
            }

            currentAngle += angleAdjustment
        }

        let unusedSpace = (rect.midY - bottomEdge) / 2

        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        return path.applying(transform)
    }
}

struct StarView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            VStack {
                
                    StarShape(corners: 5, smoothness: 0.5)
                        .stroke(lineWidth: 1)
                        .fill(Color.black)
                        .frame(width: 19, height: 19, alignment: .center)
                        .previewLayout(.fixed(width: 300, height: 300))
                        .previewDisplayName("StarView preview")
            }
            .frame(width: 100, height: 100)
            
        }.previewLayout(.sizeThatFits)
    }
}
