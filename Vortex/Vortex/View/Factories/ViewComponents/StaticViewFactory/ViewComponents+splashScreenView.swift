//
//  ViewComponents+splashScreenView.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.03.2025.
//

import RxViewModel
import SplashScreenUI
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func splashScreenView(
        splash: SplashScreenViewModel
    ) -> some View {
        
        RxWrapperView(model: splash) { state, _ in
            
            ZStack {
                
                SplashScreenImageView(state: state)
                SplashScreenContentView(state: state.phase, config: .prod)
            }
            .animation(.easeOut(duration: 2), value: state)
            .ignoresSafeArea()
        }
    }
}
