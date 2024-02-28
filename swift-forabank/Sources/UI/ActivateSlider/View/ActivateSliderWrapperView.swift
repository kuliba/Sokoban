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
                return .activateAlert()
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
