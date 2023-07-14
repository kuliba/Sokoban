//
//  CircleAnimatableAnge.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 30.05.2023.
//

import Foundation
import SwiftUI

struct CircleWithAnimatableAngle: Shape {
    
    private var angle: Float
    private let radius: Float

    private let xPosition: Float
    private let yPosition: Float
    
    var animatableData: Float {
        get { angle }
        set { angle = newValue }
    }
    
    internal init(
        angle: Float,
        radius: Float,
        xPosition: Float,
        yPosition: Float
    ) {
        self.angle = angle
        self.radius = radius
        self.xPosition = xPosition
        self.yPosition = yPosition
    }
    
    func path(in rect: CGRect) -> Path {
        
        return Path { path in
            
            let x = CGFloat(xPosition + radius * cos(angle))
            let y = CGFloat(yPosition - radius * sin(angle))
            
            path.move(to: CGPoint(x: x, y: y))
            path.addEllipse(in: CGRect(x: x - 25.0, y: y - 25.0, width: 50.0, height: 50.0))
        }
    }
}

struct CircleView: View {
    
    @State var angle: Float = Float.pi / 2.0
    let radius: Float = 200
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .strokeBorder(.black, lineWidth: 2)
                .foregroundColor(.clear)
                .frame(width: CGFloat(2*radius), height: CGFloat(2*radius))
                .position(x: 400, y: 400)
            
            CircleWithAnimatableAngle(angle: angle, radius: radius, xPosition: 400, yPosition: 400)
                .foregroundColor(.blue)
        }
        .frame(width: 800, height: 800)
        .background(Color.blue)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                angle = -Float.pi / 2.0
            }
        }
    }
}
