//
//  RootViewFactory+makeUserAccountButton.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.12.2024.
//

import SwiftUI

extension ViewComponents {
    
    func makeUserAccountToolbarButton(
        action: @escaping () -> Void
    ) -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            
            #if RELEASE
            makeUserAccountButton(action: action)
            #else
            makeUserAccountButton(action: action)
                .contextMenu {
                    
                    Button(action: {}) {//clearCache) {
                        
                        Label("Clear cache", systemImage: "trash.circle")
                    }
                }
            #endif
        }
    }
    
    func makeUserAccountButton(
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action, label: makeUpdatingUserAccountButtonLabel)
    }
}
