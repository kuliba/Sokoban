//
//  SberQRPreviewApp.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

@main
struct SberQRPreviewApp: App {
    
    private let composer: Composer
    
    init() {
        let navigationModel = NavigationModel(
            navigation: .fullScreenCover(.qrReader)
        )
        self.composer = .init(navigationModel: navigationModel)
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView(
                navigationModel: composer.navigationModel,
                mainView: composer.makeMainView,
                fullScreenCoverView: composer.makeFullScreenCoverView
            )
        }
    }
}
