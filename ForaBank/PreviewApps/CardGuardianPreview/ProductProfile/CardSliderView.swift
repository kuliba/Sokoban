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
    
    let state: ProductProfileNavigation.State
    let event: (ProductProfileNavigation.Event) -> Void
    
    var body: some View {
        
        sliderView(
            viewModel: .init(
                initialState: .status(nil),
                reduce: CardReducer().reduce(_:_:),
                handleEffect: CardEffectHandler.activateSuccess.handleEffect
            )
        )
        .alert(
            item: .init(
                get: { state.alert },
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: event) }
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
    CardSliderView(
        state: .init(),
        event: { _ in }
    )
}
