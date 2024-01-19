//
//  View+loader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.01.2024.
//

import SwiftUI

extension View {
    
    func loader(
        isLoading: Bool,
        icon: Image = .init("Logo Fora Bank")
    ) -> some View {
        
        self.modifier(LoaderWrapper(
            isLoading: isLoading,
            icon: icon
        ))
    }
}

struct LoaderWrapper: ViewModifier {
    
    let isLoading: Bool
    let icon: Image
    
    func body(content: Content) -> some View {
        
        ZStack {
            
            content
            
            ZStack {
                
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                SpinnerRefreshView(icon: icon)
            }
            .ignoresSafeArea()
            .opacity(isLoading ? 1 : 0)
        }
    }
}
