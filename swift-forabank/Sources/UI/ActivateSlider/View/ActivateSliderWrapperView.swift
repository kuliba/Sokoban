//
//  ActivateSliderWrapperView.swift
//
//
//  Created by Andryusina Nataly on 21.02.2024.
//

import SwiftUI
import RxViewModel
import UIPrimitives

typealias CardViewModel = RxViewModel<CardState, CardEvent, CardEffect>

struct ActivateSliderWrapperView: View {
    
    @ObservedObject var viewModel: CardViewModel
    
    let config: SliderConfig
    
    var body: some View {
        
        ActivateSliderView(
            viewModel: .init(
                maxOffsetX: config.maxOffsetX,
                didSwitchOn: {
                    viewModel.event(.activateCard)
                }),
            state: viewModel.state,
            event: viewModel.event,
            config: config)
        .alert(item: .init(
            get: {
                guard case .status(.confirmActivate) = viewModel.state
                else { return nil }
                return AlertModelOf(
                    title: "Confirm",
                    message: "Confirm?",
                    primaryButton: .init(type: .cancel, title: "Cancel", event: CardEvent.confirmActivate(.cancel)),
                    secondaryButton: .init(type: .default, title: "Ok", event: CardEvent.confirmActivate(.activate))
                )
            },
            set: { _ in }),
               content: { .init(with: $0, event: viewModel.event) })
    }
}

struct ActivateSliderWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            activateSuccess
            activateFailure
        }
    }
    
    static var activateSuccess: some View {
        
        ZStack {
            
            Color.gray
                .frame(width: 300, height: 100)
            
            ActivateSliderWrapperView(
                viewModel: .init(
                    initialState: .status(nil),
                    reduce: CardReducer().reduce,
                    handleEffect: CardEffectHandler.activateSuccess.handleEffect
                ),
                config: .default
            )
        }
    }
    
    static var activateFailure: some View {
        
        ZStack {
            Color.gray
                .frame(width: 300, height: 100)
            
            ActivateSliderWrapperView(
                viewModel: .init(
                    initialState: .status(nil),
                    reduce: CardReducer().reduce,
                    handleEffect: CardEffectHandler.activateFailure.handleEffect
                ),
                config: .default
            )
        }
    }
}

