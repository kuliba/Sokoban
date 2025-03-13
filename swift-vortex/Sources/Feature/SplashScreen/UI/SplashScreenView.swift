//
//  SplashScreenView.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenView: View {
    
    private let state: SplashScreenState
    private let image: Image
    
    public init(
        state: SplashScreenState,
        image: Image
    ) {
        self.state = state
        self.image = image
    }
    
    public var body: some View {
        
        image
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

//#Preview {
//    
//    SplashScreenView()
//}

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
