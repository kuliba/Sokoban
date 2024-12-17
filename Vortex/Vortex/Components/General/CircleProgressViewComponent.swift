//
//  CircleProgressViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import SwiftUI

struct CircleProgressView: View {
    
    @Binding var progress: Double
    
    let color: Color
    let backgroundColor: Color
    let width: CGFloat = 2

    var body: some View {
        
        ZStack {
            Circle()
                .stroke(lineWidth: width)
                .foregroundColor(backgroundColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
        }
    }
}

struct CircleProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        CircleProgressView(progress: .constant(0.75), color: Color(hex: "#999999"), backgroundColor: Color(hex: "#EAEBEB"))
            .previewLayout(.fixed(width: 50, height: 50))
    }
}
