//
//  View+loader.swift
//  Vortex
//
//  Created by Igor Malyarov on 10.01.2024.
//

import SwiftUI

extension View {
    
    func loaderOverlay(
        isLoading: Bool
    ) -> some View {
        
        overlay {
            
            SpinnerRefreshView(icon: .init("Logo Vortex"))
                .opacity(isLoading ? 1 : 0)
        }
    }
    
    func loader(
        isLoading: Bool,
        icon: Image = .init("Logo Vortex"),
        color: Color = .black.opacity(0.3)
    ) -> some View {
        
        self.modifier(LoaderWrapper(
            isLoading: isLoading,
            icon: icon,
            color: color
        ))
    }
}

struct LoaderWrapper: ViewModifier {
    
    let isLoading: Bool
    let icon: Image
    var color: Color = .black.opacity(0.3)
    
    func body(content: Content) -> some View {
        
        ZStack {
            
            content
              //  .disabled(isLoading)
            
            ZStack {
                
                color
                    .ignoresSafeArea()
                
                SpinnerRefreshView(icon: icon)
            }
            .ignoresSafeArea()
            .opacity(isLoading ? 1 : 0)
        }
    }
}
