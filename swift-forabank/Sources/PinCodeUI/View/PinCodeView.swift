//
//  PinCodeView.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import SwiftUI

public struct PinCodeView: View {
    
    @ObservedObject public var viewModel: PinCodeViewModel
    public let config: PinCodeConfig
    
    public init(
        viewModel: PinCodeViewModel,
        config: PinCodeConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            Text(viewModel.state.titleForView)
                .font(config.font)
                .foregroundColor(config.foregroundColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.leading, 46)
                .padding(.trailing, 45)
                .padding(.bottom, 12)

            if !viewModel.state.hideHint {
                
                HintView()
            }
            
            HStack(spacing: 16) {
                
                ForEach(viewModel.dots.indices, id: \.self) { index in
                    
                    DotView(
                        viewModel: viewModel.dots[index],
                        colors: config.colorsForPin,
                        style: viewModel.state.currentStyle
                    )
                }
                .modifier(PinCodeView.Shake(animatableData: CGFloat(viewModel.mistakes)))
            }
            .padding(.top, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.trailing, 15)
        .padding(.leading, 16)
    }
    
    public struct DotView: View {
        
        private let color: Color
        let size: CGFloat
        let duration: TimeInterval
        
        public init(
            viewModel: PinCodeViewModel.DotViewModel,
            colors: PinCodeView.DotView.ColorsForPin,
            style: PinCodeViewModel.Style,
            size: CGFloat = 12,
            duration: TimeInterval = 1.0
        ) {
            
            self.color = colors.colorByStyle(style, isFilled: viewModel.isFilled)
            self.size = size
            self.duration = duration
        }
        
        public var body: some View {
                       
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }
}

extension PinCodeView {
    
    struct Shake: GeometryEffect {
        
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
    }
}

struct PinCodeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PinCodeView(
            viewModel: .defaultValue,
            config: .init(
                font: .body,
                foregroundColor: .blue,
                colorsForPin: .colorsForDots)
        )
    }
}

extension Array where Element == PinCodeViewModel.DotViewModel {
    
    static let dots: Self = [
        .init(isFilled: true),
        .init(isFilled: true),
        .init(isFilled: false),
        .init(isFilled: false)
    ]
}
