//
//  SplashScreenView.swift
//
//
//  Created by Nikolay Pochekuev on 20.12.2024.
//

import SwiftUI

public struct SplashScreenView: View {

    @Binding private var showSplash: Bool
    private let config: Config
    private let data: Data

    public init(showSplash: Binding<Bool>, config: Config, data: Data) {
        
        self._showSplash = showSplash
        self.config = config
        self.data = data
        
    }

    public var body: some View {
        
        ZStack {
            
            (data.backgroundImage ?? config.defaultBackgroundImage)
                .resizable()
                .ignoresSafeArea(edges: .top)
                .scaledToFill()
                .scaleEffect(showSplash ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 1.2), value: showSplash)
            
            VStack {
                
                (data.logoImage ?? config.defaultLogoImage)
                    .resizable()
                    .frame(
                        width: config.sizes.iconSize,
                        height: config.sizes.iconSize
                    )
                    .padding(.bottom, config.paddings.imageBottomPadding)
                
                Text(data.dayTimeText)
                Text(data.userNameText)
            }
            .padding(.bottom, config.paddings.bottomPadding)
        }
    }
}

public extension SplashScreenView {
    
    typealias Config = SplashScreenConfig
    typealias Data = SplashScreenData
}

#Preview {
        
    SplashScreenPreview(showSplash: true)
}

struct SplashScreenPreview: View {
    
    @State var showSplash: Bool
    
    var body: some View {
        
        SplashScreenView(showSplash: $showSplash, config: .default, data: .preview)
    }
}
