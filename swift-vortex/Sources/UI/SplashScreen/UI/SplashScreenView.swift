//
//  SplashScreenView.swift
//
//
//  Created by Nikolay Pochekuev on 20.12.2024.
//

import SwiftUI

public struct SplashScreenView: View {

    @State private var showSplash: Bool = false
    private let config: Config
    private let data: Data

    public init(showSplash: Bool, config: Config, data: Data) {
        
        self.showSplash = showSplash
        self.config = config
        self.data = data
    }

    public var body: some View {
        
        ZStack {
            
            config.backgroundImage
                .resizable()
                .scaledToFill()
                .foregroundColor(.blue)
                .scaleEffect(showSplash ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.2), value: showSplash)
            
            VStack {
                
                config.logoImage
                    .resizable()
                    .frame(
                        width: config.sizes.iconSize,
                        height: config.sizes.iconSize
                    )
                    .padding(.bottom, config.paddings.imageBottomPadding)
                
                Text(config.strings.dayTimeText)
                Text(config.strings.userNameText)
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
        
        SplashScreenView(showSplash: showSplash, config: .default, data: .preview)
    }
}
