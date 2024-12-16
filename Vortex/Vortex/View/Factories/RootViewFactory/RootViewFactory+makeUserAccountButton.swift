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
            
            makeUserAccountButton(action: action)
        }
    }
    
    func makeUserAccountButton(
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action, label: makeUpdatingUserAccountButtonLabel)
    }
}
