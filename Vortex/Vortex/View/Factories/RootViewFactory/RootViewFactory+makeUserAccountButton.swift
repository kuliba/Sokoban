//
//  RootViewFactory+makeUserAccountButton.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.12.2024.
//

import SwiftUI

extension RootViewFactory {
    
    func makeUserAccountToolbarButton(
        action: @escaping () -> Void
    ) -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            
            #if RELEASE
            makeUserAccountButton(action: action)
            #else
            makeUserAccountButton(action: action)
                .contextMenu {
                    
                    Button("Clear segmented operators cache", action: clearCache)
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
