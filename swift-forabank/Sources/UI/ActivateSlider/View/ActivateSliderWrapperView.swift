//
//  ActivateSliderWrapperView.swift
//
//
//  Created by Andryusina Nataly on 21.02.2024.
//

import SwiftUI
import RxViewModel
import UIPrimitives

public typealias CardViewModel = RxViewModel<CardState, CardEvent, CardEffect>

public struct ActivateSliderWrapperView: View {
    
    @ObservedObject var viewModel: CardViewModel
    
    let config: SliderConfig
    
    public init(
        viewModel: CardViewModel,
        config: SliderConfig
    ) {
        self.viewModel = viewModel
        self.config = config
    }
    
    public var body: some View {
        
        ActivateSliderView(
            viewModel: .init(
                maxOffsetX: config.maxOffsetX,
                didSwitchOn: {
                    viewModel.event(.activateCard)
                }),
            state: viewModel.state,
            event: viewModel.event,
            config: config)
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

