//
//  ThreeBounceView.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 05.06.2023.
//

import Foundation
import SwiftUI
import Combine

struct ThreeBounceAnimationView: View {
    
    struct AnimationData {
        var delay: TimeInterval
    }

    static let animation = [
        AnimationData(delay: 0.0),
        AnimationData(delay: 0.2),
        AnimationData(delay: 0.4),
    ]

    @State var scales: [CGFloat] = animation.map { _ in return 0 }

    var animation = Animation.easeInOut.speed(0.4)
    let color: Color
    
    var body: some View {
        
        HStack {
            
            DotView(scale: .constant(scales[0]), color: color)
            DotView(scale: .constant(scales[1]), color: color)
            DotView(scale: .constant(scales[2]), color: color)
        }
        .onAppear {
            animateDots()
        }
    }

    func animateDots() {
        for (index, data) in Self.animation.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + data.delay) {
                animateDot(binding: $scales[index], animationData: data)
            }
        }

        //Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animateDots()
        }
    }

    func animateDot(binding: Binding<CGFloat>, animationData: AnimationData) {
        withAnimation(animation) {
            binding.wrappedValue = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(animation) {
                binding.wrappedValue = 0.1
            }
        }
    }
}

private struct DotView: View {
    
    @Binding var scale: CGFloat
    let color: Color
    
    var body: some View {
        
        Circle()
            .scale(scale)
            .fill(color.opacity(scale >= 0.7 ? scale : scale - 0.1))
            .frame(width: 4, height: 4, alignment: .center)
    }
}

struct ThreeBounceAnimation_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ThreeBounceAnimationView(color: .white)
            .background(Color.red)
    }
}
