//
//  SplashScreenContentView.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI
import UIPrimitives

public struct SplashScreenContentView: View {
    
    private let state: SplashScreenState
    private let config: SplashScreenContentViewConfig
    
    public init(
        state: SplashScreenState,
        config: SplashScreenContentViewConfig
    ) {
        self.state = state
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            logo(state.settings.logo)
            text(state.settings.text)
            state.settings.subtext.map(subtext)
            Spacer()
            footer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(config.edges)
        .blur(radius: state.phase.blurRadius)
        .opacity(state.phase.opacity)
    }
}

private extension SplashScreenContentView {
    
    func logo(
        _ settings: SplashScreenState.Settings.Logo
    ) -> some View {
        
        config.logo
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(settings.color)
            .frame(config.logoFrame)
            .shadow(settings.shadow)
    }
    
    func footer() -> some View {
        
        config.footer
            .renderingMode(.template)
            .foregroundColor(state.settings.footer.color)
            .shadow(state.settings.footer.shadow)
            .padding(.vertical, config.footerVPadding)
    }
    
    func text(
        _ settings: SplashScreenState.Settings.Text
    ) -> some View {
        
        settings.value.text(
            withConfig: .init(textFont: config.textFont, textColor: settings.color),
            alignment: .center
        )
        .shadow(settings.shadow)
    }
    
    func subtext(
        _ settings: SplashScreenState.Settings.Text
    ) -> some View {
        
        settings.value.text(
            withConfig: .init(textFont: config.subtextFont, textColor: settings.color),
            alignment: .center
        )
        .shadow(settings.shadow)
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

private extension SplashScreenContentViewConfig {
    
    var logoFrame: CGSize { .init(width: logoSize, height: logoSize) }
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
        
        SplashScreenContentView(
            state: .init(phase: phase, settings: .preview),
            config: .preview
        )
    }
}
