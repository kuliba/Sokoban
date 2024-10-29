//
//  ContentViewFullScreenView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import SwiftUI

struct ContentViewFullScreenView: View {
    
    let fullScreen: ContentViewDomain.Flow.FullScreen
    
    var body: some View {
        
        switch fullScreen {
        case let .qr(binder):
            NavigationView {
                
                ZStack(alignment: .bottom) {
                    
                    ZStack(alignment: .top) {
                        
                        Color.clear
                        
                        QRView(binder: binder)
                    }
                    
                    Button("Cancel* - see print") {
                        
                        print("dismiss: in the app QRModelWrapper has state case `cancelled` - which should be observed")
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
