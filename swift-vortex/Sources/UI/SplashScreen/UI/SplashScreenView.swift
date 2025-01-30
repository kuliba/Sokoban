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
        
        splash.data.state != .start ? config.scaleEffect.end : config.scaleEffect.start
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
                                
                splash.data.message.map {
                    
                    $0.text(withConfig: splash.config.message)
                }
                
                Spacer()
                
                splash.data.footer.map {
                    
                    $0.text(withConfig: splash.config.footer)
                }
            }
            .padding(.horizontal)
            .padding(.top, config.paddings.top)
            .padding(.bottom, config.paddings.bottom)
        }
        .opacity(splash.data.state == .splash ? 1 : 0)
        .animation(
            splash.data.animation,
            value: splash.data.state
        )
    }
}

private extension SplashScreenView {
    
    func splashBackground() -> some View {
        
        splash.data.background
            .resizable()
            .scaledToFill()
            .scaleEffect(scaleEffect)
            .animation(
                splash.data.animation,
                value: splash.data.state
            )
            .ignoresSafeArea()
    }
}

#Preview {
    SplashScreenPreview()
}

struct SplashScreenPreview: View {
    
    @State private var splash: Splash = .init(data: .preview, config: .preview)
    @State private var showSplash: Bool = true
    
    var body: some View {
        
        SplashScreenView(splash: splash, config: .preview)
            .onChange(of: showSplash) { newValue in
                splash.data.state = newValue ? .start : .splash
            }
            .overlay {
                Toggle("showSplash", isOn: $showSplash)
                    .labelsHidden()
                    .padding()
            }
    }
}

#Preview("Zoom Phase") {
    SplashScreenZoomPreview()
}

struct SplashScreenZoomPreview: View {
    
    @State private var splash: Splash = .init(data: .preview, config: .preview)
    @State private var showSplash: Bool = true
    
    var body: some View {
        
        SplashScreenView(splash: splash, config: .preview)
            .onChange(of: showSplash) { newValue in
                splash.data.state = newValue ? .start : .splash
            }
            .overlay {
                Toggle("showSplash", isOn: $showSplash)
                    .labelsHidden()
                    .padding()
            }
    }
}

#Preview("FadeOut") {
    SplashScreenFadeOutPreview()
}

struct SplashScreenFadeOutPreview: View {
    
    @State private var splash: Splash = .init(data: .preview, config: .preview)
    @State private var showSplash: Bool = true
    
    var body: some View {
        
        SplashScreenView(splash: splash, config: .preview)
            .onChange(of: showSplash) { newValue in
                splash.data.state = newValue ? .splash : .noSplash
            }
            .overlay {
                Toggle("showSplash", isOn: $showSplash)
                    .labelsHidden()
                    .padding()
            }
    }
}
