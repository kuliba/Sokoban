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
    // StateObject need
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
            
            ActivateSliderWrapperView(
                viewModel: .init(
                    initialState: .initialState,
                    reduce: CardActivateReducer.reduceForPreview(),
                    handleEffect: CardActivateEffectHandler.handleEffectActivateFailure()),
                config: .default
            )
        }
    }
}

