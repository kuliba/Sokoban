//
//  CircleSegmentedBarView.swift
//  ForaBank
//
//  Created by Дмитрий on 22.03.2022.
//

import SwiftUI
import Combine

struct CircleSegmentedBarView: View {
    
    @Binding var progress: CGFloat
    var width: CGFloat = 4
    var primaryColor: Color = .red
    var secondaryColor: Color = .gray
    
    private var gap: CGFloat { progress > 0 ? 0.03 : 0 }
    
    var body: some View {

        ZStack {
            
            Circle()
                .trim(from: 0 + gap, to: max(min(1 - progress, 1), 0) - gap)
                .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                .foregroundColor(secondaryColor)
                .rotationEffect(Angle(degrees: 270))
                .scaleEffect(CGSize(width: -1, height: 1))
                .padding(max(width / 2, 0))
            
            Circle()
                .trim(from: 0.0, to: max(min(progress, 1), 0))
                .stroke(style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
                .foregroundColor(primaryColor)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(max(width / 2, 0))
        }
    }
}

struct CircleSegmentedBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CircleSegmentedBarView(progress: .constant(0))
                .previewLayout(.fixed(width: 96, height: 96))
            
            CircleSegmentedBarView(progress: .constant(0.35))
                .previewLayout(.fixed(width: 96, height: 96))
            
            CircleSegmentedBarView(progress: .constant(0.5))
                .previewLayout(.fixed(width: 96, height: 96))
            
            CircleSegmentedBarView(progress: .constant(0.75))
                .previewLayout(.fixed(width: 96, height: 96))
            
            CircleSegmentedBarView(progress: .constant(1.0))
                .previewLayout(.fixed(width: 96, height: 96))
        }
    }
}

