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
    
    let viewModel: CardViewWithSliderModel
    let config: SliderConfig
    
    var body: some View {
        
        ActivateSliderWrapperView(
            viewModel: viewModel,
            config: config
        )
    }
}

#Preview {
    CardSliderView(
        viewModel: .init(
            viewModel: .init(
                initialState: .status(nil),
                reduce: CardReducer().reduce,
                handleEffect: CardEffectHandler.activateSuccess.handleEffect
            ),
            maxOffsetX: SliderConfig.default.maxOffsetX),
        config: .default)
}
