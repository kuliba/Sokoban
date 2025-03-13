//
//  SplashScreenContentView.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenContentView: View {
    
    private let state: SplashScreenState.Phase
    
    public init(state: SplashScreenState.Phase) {
        
        self.state = state
    }
    
    public var body: some View {
        
        VStack {
            
            Text("Hello!")
                .font(.largeTitle.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .blur(radius: state.blurRadius)
        .opacity(state.opacity)
    }
}

private extension SplashScreenState.Phase {
    
    var blurRadius: Double {
        
        switch self {
        case .cover, .warm, .presented:
            return -100
        case .hidden:
            return 100
        }
    }
    
    var opacity: Double {
        
        switch self {
        case .cover, .hidden:   return 0
        case .warm, .presented: return 2
        }
    }
}

// MARK: - Previews

struct SplashScreenContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            contentView(.presented)
                .previewDisplayName("presented")
            contentView(.warm)
                .previewDisplayName("warm")
            contentView(.cover)
                .previewDisplayName("cover")
            contentView(.hidden)
                .previewDisplayName("hidden")
        }
    }
    
    static func contentView(
        _ phase: SplashScreenState.Phase
    ) -> some View {
        
        SplashScreenContentView(state: phase)
    }
}
