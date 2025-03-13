//
//  SplashScreenView.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI

public struct SplashScreenView: View {
    
    private let state: SplashScreenState
    
    public init(state: SplashScreenState) {
        
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

// MARK: - Previews

struct SplashScreenView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            splashScreenView(.presented)
                .previewDisplayName("presented")
            splashScreenView(.warm)
                .previewDisplayName("warm")
            splashScreenView(.cover)
                .previewDisplayName("cover")
            splashScreenView(.hidden)
                .previewDisplayName("hidden")
        }
        .background(Color.blue)
    }
    
    private static func splashScreenView(
        _ phase: SplashScreenState.Phase
    ) -> some View {
        
        SplashScreenView(
            state: .init(
                phase: phase,
                settings: .init(image: image())
            )
        )
        .ignoresSafeArea()
    }
    
    private static func image(
        named name: String = "MORNING2",
        withExtension ext: String = "jpg"
    ) -> Image {
        
        // `Image(name, bundle: .module)` does not work in preview
        guard
            let url = Bundle.module.url(forResource: name, withExtension: ext),
            let data = try? Data(contentsOf: url),
            let uiImage = UIImage(data: data)
        else {
            
            print("No image \"\(name).\(ext)\"")
            return .init(systemName: "star")
        }
        
        return Image(uiImage: uiImage)
    }
}
