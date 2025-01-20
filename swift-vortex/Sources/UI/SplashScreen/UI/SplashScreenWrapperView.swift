//
//  SplashScreenWrapperView.swift
//  
//
//  Created by Nikolay Pochekuev on 24.12.2024.
//

import SwiftUI

public struct SplashScreenWrapperView: View {
    
    @State var showSplash: Bool
    private let data: SplashScreenData
    private let config: SplashScreenConfig
    
    public init(
        showSplash: Bool,
        data: SplashScreenData,
        config: SplashScreenConfig
    ) {
        self.showSplash = showSplash
        self.data = data
        self.config = config
    }

    public var body: some View {
        
        SplashScreenView(showSplash: showSplash, config: config, data: data)
    }
}
