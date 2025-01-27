//
//  SplashScreenView.swift
//
//
//  Created by Nikolay Pochekuev on 20.12.2024.
//

import SwiftUI
import UIPrimitives

public struct SplashScreenView: View {
    
    private let splash: Splash
    private let config: SplashScreenStaticConfig
    
    public init(splash: Splash, config: SplashScreenStaticConfig) {
        self.splash = splash
        self.config = config
    }
    
    private var dynamicConfig: SplashScreenDynamicConfig { splash.config }
    
    private var scaleEffect: CGFloat {
        
        splash.data.showSplash ? config.scaleEffect.end : config.scaleEffect.start
    }
    
    public var body: some View {
        
        ZStack {
            
            splashBackground()
            
            VStack(spacing: config.spacing) {
                
                splash.data.logo.map {
                    
                    $0
                        .resizable()
                        .frame(config.logoSize)
                }
                
                splash.data.greeting.map {
                    
                    $0.text(withConfig: splash.config.greeting)
                }
                
                Spacer()
                
                splash.data.footer.map {
                    
                    $0.text(withConfig: splash.config.footer)
                }
            }
            .padding(.top, config.paddings.top)
            .padding(.bottom, config.paddings.bottom)
        }
        .opacity(splash.data.showSplash ? 1 : 0.1) // TODO: improve
    }
}

private extension SplashScreenView {
    
    func splashBackground() -> some View {
        
        splash.data.background
            .resizable()
            .scaledToFill()
            .scaleEffect(scaleEffect)
            .animation(splash.data.animation, value: splash.data.showSplash)
            .ignoresSafeArea()
    }
}

#Preview {
    
    SplashScreenPreview()
}

struct SplashScreenPreview: View {
    
    @State private var splash: Splash = .init(data: .preview, config: .preview)
    
    var body: some View {
        
        SplashScreenView(splash: splash, config: .preview)
            .overlay {
                
                Toggle("showSplash", isOn: $splash.data.showSplash)
                    .labelsHidden()
                    .padding()
            }
    }
}
