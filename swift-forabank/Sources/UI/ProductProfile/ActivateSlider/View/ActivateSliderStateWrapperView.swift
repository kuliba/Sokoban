//
//  ActivateSliderStateWrapperView.swift
//
//
//  Created by Andryusina Nataly on 06.05.2024.
//

import SwiftUI
import RxViewModel
import UIPrimitives

public struct ActivateSliderStateWrapperView: View {
    
    @StateObject var viewModel: ActivateSliderViewModel
    let payload: ActivatePayload
    
    let config: SliderConfig
    
    public typealias ActivatePayload = Int

    public init(
        payload: ActivatePayload,
        viewModel: ActivateSliderViewModel,
        config: SliderConfig
    ) {
        self.payload = payload
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    public var body: some View {
        
        ActivateSliderView(
            state: viewModel.state,
            event: { viewModel.event(.slider(payload, $0)) },
            config: config
        )
        .alert(item: .init(
            get: {
                guard case .status(.confirmActivate) = viewModel.state.cardState
                else { return nil }
                return .activateAlert(payload)
            },
            set: { _ in }),
               content: { .init(with: $0, event: viewModel.event) })
    }
}

struct ActivateSliderStateWrapperView_Previews: PreviewProvider {
    
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
            
            ActivateSliderStateWrapperView(
                payload: 1,
                viewModel: .init(
                    initialState: .initialState,
                    reduce: CardActivateReducer.reduceForPreview(),
                    handleEffect: CardActivateEffectHandler.handleEffectActivateSuccess()),
                config: .default
            )
        }
    }
    
    static var activateFailure: some View {
        
        ZStack {
            Color.gray
                .frame(width: 300, height: 100)
            
            ActivateSliderStateWrapperView(
                payload: 2,
                viewModel: .init(
                    initialState: .initialState,
                    reduce: CardActivateReducer.reduceForPreview(),
                    handleEffect: CardActivateEffectHandler.handleEffectActivateFailure()),
                config: .default
            )
        }
    }
}
