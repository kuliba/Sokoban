//
//  ViewComponents+splashScreenView.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.03.2025.
//

import RxViewModel
import SplashScreenUI
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func splashScreenView(
        splash: SplashScreenViewModel
    ) -> some View {
        
        RxWrapperView(model: splash) { state, _ in
            
            Image("splash")
                .renderingMode(state.renderingMode)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(state.foregroundColor)
                .blur(radius: state.blurRadius)
                .opacity(state.opacity)
                .scaleEffect(state.scaleEffect)
                .animation(nil, value: state.foregroundColor)
                .animation(.easeOut(duration: 2), value: state)
        }
    }
}

// MARK: - UI Mapping

extension SplashScreenState {
    
    var renderingMode: Image.TemplateRenderingMode {
        
        switch self {
        case .cover: return .template
        default:     return .original
        }
    }
    
    var foregroundColor: Color {
        
        switch self {
        case .cover: return .white
        default:     return .clear
        }
    }
    
    var scaleEffect: CGFloat {
        
        switch self {
        case .cover, .warm:
            return 1
        case .presented:
            return 1.025
        case .hidden:
            return 1.05
        }
    }
    
    var opacity: Double {
        
        switch self {
        case .cover, .warm, .presented:
            return 2
        case .hidden:
            return 0
        }
    }
    
    var blurRadius: Double {
        
        switch self {
        case .cover, .warm, .presented:
            return -100
        case .hidden:
            return 20
        }
    }
}
