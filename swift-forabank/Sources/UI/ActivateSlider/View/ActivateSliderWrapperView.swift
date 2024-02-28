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
    
    @ObservedObject var viewModel: GlobalViewModel
    
    let config: SliderConfig
    
    public init(
        viewModel: GlobalViewModel,
        config: SliderConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        ActivateSliderView(
            state: viewModel.state,
            event: { viewModel.event(.slider($0)) },
            config: config
        )
        .alert(item: .init(
            get: {
                guard case .status(.confirmActivate) = viewModel.state.cardState
                else { return nil }
                return AlertModelOf(
                    title: "Активировать карту?",
                    message: "После активации карта будет готова к использованию",
                    primaryButton: .init(
                        type: .cancel,
                        title: "Отмена",
                        event: GlobalEvent.card(.confirmActivate(.cancel))
                    ),
                    secondaryButton: .init(
                        type: .default,
                        title: "ОК",
                        event: GlobalEvent.card(.confirmActivate(.activate))
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
                    initialState: .initialState,
                    reduce: GlobalReducer.preview(maxOffsetX: .maxOffsetX).reduce(_:_:),
                    handleEffect: GlobalEffectHandler(handleCardEffect: CardEffectHandler.activateSuccess.handleEffect(_:_:)).handleEffect(_:_:)),
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
                    initialState: .initialState,
                    reduce: GlobalReducer.preview(maxOffsetX: .maxOffsetX).reduce(_:_:),
                    handleEffect: GlobalEffectHandler(handleCardEffect: CardEffectHandler.activateFailure.handleEffect(_:_:)).handleEffect(_:_:)),
                config: .default
            )
        }
    }
}

public extension GlobalReducer {
    
    static func preview(
        maxOffsetX: CGFloat
    ) -> GlobalReducer {
        
        .init(
            cardReduce: CardReducer().reduce,
            sliderReduce: SliderReducer(
                maxOffsetX: SliderConfig.default.maxOffsetX
            ).reduce,
            maxOffset: SliderConfig.default.maxOffsetX
        )
    }
}

public extension CGFloat {
    
    static let maxOffsetX = SliderConfig.default.maxOffsetX
}

public extension GlobalState {
    
    static let initialState = GlobalState(cardState: .status(nil), offsetX: 0)
}
