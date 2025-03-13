//
//  SplashScreenView.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenView: View {
    
    private let state: SplashScreenState
    
    public init(
        state: SplashScreenState
    ) {
        self.state = state
    }
    
    public var body: some View {
        
        state.settings.image
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

private extension SplashScreenState {
    
    var renderingMode: Image.TemplateRenderingMode {
        
        switch phase {
        case .cover: return .template
        default:     return .original
        }
    }
    
    var foregroundColor: Color {
        
        switch phase {
        case .cover: return .white
        default:     return .clear
        }
    }
    
    var scaleEffect: CGFloat {
        
        switch phase {
        case .cover, .warm:
            return 1
        case .presented:
            return 1.025
        case .hidden:
            return 1.05
        }
    }
    
    var opacity: Double {
        
        switch phase {
        case .cover, .warm, .presented:
            return 2
        case .hidden:
            return 0
        }
    }
    
    var blurRadius: Double {
        
        switch phase {
        case .cover, .warm, .presented:
            return -100
        case .hidden:
            return 20
        }
    }
}
