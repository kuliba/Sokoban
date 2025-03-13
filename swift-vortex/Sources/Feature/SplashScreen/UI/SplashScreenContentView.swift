//
//  SplashScreenContentView.swift
//
//
//  Created by Igor Malyarov on 13.03.2025.
//

import SwiftUI
import UIPrimitives

struct SplashScreenSettings: Equatable {
    
    let bank: Logo
    let name: Logo
    let text: Text
    let subtext: Text?
    
    struct Logo: Equatable {
        
        let color: Color
        let shadow: Shadow
    }
    
    struct Text: Equatable {
        
        let color: Color
        let size: CGFloat // TODO: ???
        let value: String
        let shadow: Shadow
    }
    
    struct Shadow: Equatable {
        
        let color: Color
        let opacity: Double
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

extension SplashScreenSettings.Shadow {
    
    static let logo: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
    static let name: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
    static let text: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
    static let subtext: Self = .init(color: .black, opacity: 1, radius: 12, x: 0, y: 4)
}

extension SplashScreenSettings {
    
    static let preview: Self = .init(
        bank: .init(color: .blue, shadow: .logo),
        name: .init(color: .pink, shadow: .name),
        text: .init(color: .green, size: 24, value: "Hello, world!", shadow: .text),
        subtext: .init(color: .blue, size: 16, value: "A long quite boring subtext to kill user attention.", shadow: .subtext)
    )
}

public struct SplashScreenContentView: View {
    
    private let state: SplashScreenState.Phase
    private let settings: SplashScreenSettings = .preview
    private let config: SplashScreenContentViewConfig
    
    public init(
        state: SplashScreenState.Phase,
        config: SplashScreenContentViewConfig
    ) {
        self.state = state
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            logo(settings.bank)
            
            text(settings.text)
            
            settings.subtext.map(subtext)
            
            Spacer()
            
            name()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(config.edges)
        .blur(radius: state.blurRadius)
        .opacity(state.opacity)
    }
}

private extension SplashScreenContentView {
    
    func logo(
        _ settings: SplashScreenSettings.Logo
    ) -> some View {
        
        config.logo
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundColor(settings.color)
            .frame(config.logoFrame)
            .shadow(settings.shadow)
    }
    
    func name() -> some View {
        
        config.name
            .renderingMode(.template)
            .foregroundColor(config.nameColor)
            .shadow(settings.name.shadow)
            .padding(.vertical, config.nameVPadding)
    }
    
    func text(
        _ settings: SplashScreenSettings.Text
    ) -> some View {
        
        settings.value.text(
            withConfig: .init(textFont: config.textFont, textColor: settings.color),
            alignment: .center
        )
    }
    
    func subtext(
        _ settings: SplashScreenSettings.Text
    ) -> some View {
        
        settings.value.text(
            withConfig: .init(textFont: config.subtextFont, textColor: settings.color),
            alignment: .center
        )
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
        
        SplashScreenContentView(state: phase, config: .preview)
    }
}
