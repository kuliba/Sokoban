//
//  ViewComponents+splashView.swift
//  Vortex
//
//  Created by Igor Malyarov on 12.03.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    // TODO: - add/extract config
    @inlinable
    func splashView(
        splash: SplashScreenViewModel
    ) -> some View {
        
        RxWrapperView(model: splash) { state, _ in
            
            switch state {
            case .cover:
                Color.white
                
            case .hidden:
                EmptyView()
                
            case .presented:
                Color.blue
                
            case .warm:
                Color.green
            }
        }
    }
}
