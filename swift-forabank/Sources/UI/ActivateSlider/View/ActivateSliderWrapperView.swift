//
//  ActivateSliderWrapperView.swift
//
//
//  Created by Andryusina Nataly on 21.02.2024.
//

import SwiftUI
import RxViewModel
import UIPrimitives

public struct ActivateSliderWrapperView: View {
    
    @ObservedObject var viewModel: CardWithSliderViewModel
    
    let config: SliderConfig
    
    public init(
        viewModel: CardWithSliderViewModel,
        config: SliderConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        ActivateSliderView(
            viewModel: viewModel.sliderViewModel,
            state: viewModel.state,
            event: viewModel.event,
            config: config)
        .alert(item: .init(
            get: {
                guard case .status(.confirmActivate) = viewModel.state
                else { return nil }
                return AlertModelOf(
                    title: "Активировать карту?",
                    message: "После активации карта будет готова к использованию",
                    primaryButton: .init(
                        type: .cancel,
                        title: "Отмена",
                        event: CardEvent.confirmActivate(.cancel)
                    ),
                    secondaryButton: .init(
                        type: .default,
                        title: "ОК",
                        event: CardEvent.confirmActivate(.activate)
                    )
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
                    viewModel: .init(
                        initialState: .status(nil),
                        reduce: CardReducer().reduce,
                        handleEffect: CardEffectHandler.activateSuccess.handleEffect
                    ),
                    maxOffsetX: SliderConfig.default.maxOffsetX),
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
                    viewModel: .init(
                        initialState: .status(nil),
                        reduce: CardReducer().reduce,
                        handleEffect: CardEffectHandler.activateFailure.handleEffect
                    ),
                    maxOffsetX: SliderConfig.default.maxOffsetX),
                config: .default
            )
        }
    }
}
