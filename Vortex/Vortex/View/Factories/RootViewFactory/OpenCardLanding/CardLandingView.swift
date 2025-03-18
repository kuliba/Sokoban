//
//  CardLandingView.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 13.03.2025.
//

import SwiftUI
import OrderCardLandingComponent

struct CardLandingView<LandingView: View>: View {
    
    @Environment(\.openURL) private var openURL
    let `continue`: () -> Void
    let makeContentView: (@escaping (ProductLandingEvent) -> Void) -> LandingView
    
    var body: some View {
        
        makeContentView { event in
            
            switch event {
            case .order:
                `continue`()
                
            case let .info(url):
                openURL(url)
            }
        }
    }
}
