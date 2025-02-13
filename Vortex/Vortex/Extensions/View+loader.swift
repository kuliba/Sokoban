//
//  View+loader.swift
//  Vortex
//
//  Created by Igor Malyarov on 10.01.2024.
//

import FlowCore
import RxViewModel
import SwiftUI

extension View {
    
    @inlinable
    func disablingLoading<Select, Navigation>(
        flow: FlowCore.FlowDomain<Select, Navigation>.Flow,
        icon: Image = .init("Logo Vortex"),
        color: Color = .black.opacity(0.3)
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            self.disablingLoading(isLoading: state.isLoading, icon: icon, color: color)
        }
    }
    
    @inlinable
    func disablingLoading(
        isLoading: Bool,
        icon: Image = .init("Logo Vortex"),
        color: Color = .black.opacity(0.3)
    ) -> some View {
        
        self.disabled(isLoading)
            .loader(isLoading: isLoading, icon: icon, color: color)
    }

    @usableFromInline
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
                .disabled(isLoading)
            
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
