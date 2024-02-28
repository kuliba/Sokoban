//
//  CardSliderView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 26.02.2024.
//

import SwiftUI
import ActivateSlider
import ProductProfile
import UIPrimitives

struct CardSliderView: View {
    
    var body: some View {
        
        sliderView(
            viewModel: .init(
                initialState: .status(nil),
                reduce: CardReducer().reduce(_:_:),
                handleEffect: CardEffectHandler.activateSuccess.handleEffect
            )
        )
    }
    
    private func sliderView(
        viewModel: CardViewModel
    ) -> some View {
        
        ActivateSliderWrapperView(
            viewModel: viewModel,
            config: .default
        )
    }
}

#Preview {
    CardSliderView()
}
