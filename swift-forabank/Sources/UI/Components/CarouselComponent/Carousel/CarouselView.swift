//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

public struct CarouselView: View {
    
    let state: CarouselState
    let event: (CarouselEvent) -> Void
    
    public var body: some View {
        
        switch state {
        case .initial(let configuration):
            
            carouselView(configuration)
        }
    }
}

extension CarouselView {
    
    @ViewBuilder
    private func carouselView(
        _ configuration: CarouselState.Configuration
    ) -> some View {
        
        switch configuration.appearance {
        case .main:
            mainCarouselView(configuration)
            
        case .profile:
            // TODO: - Профиль
            EmptyView()
            
        case .myProducts:
            // TODO: - Мои продукты
            EmptyView()
            
        case .payments:
            // TODO: - Переводы
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func mainCarouselView(
        _ configuration: CarouselState.Configuration
    ) -> some View {
        
        EmptyView()
    }
}
