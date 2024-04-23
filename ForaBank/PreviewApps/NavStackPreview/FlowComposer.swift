//
//  UtilityServicePaymentFlowComposer.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Combine
import CombineSchedulers
import Foundation
import SwiftUI
import UIPrimitives

enum FlowComposer<Icon> {}

extension FlowComposer {
    
    static func makeUtilityServicePaymentFlowView(
        initialState: UtilityServicePaymentFlowState<Icon>,
        config: UtilityPaymentConfig
    ) -> UtilityServicePaymentFlowView {
        
        .init(
            viewModel: .make(
                initialState: initialState
            ),
            factory: .make(
                initialState: initialState.operatorPickerState,
                makeImageSubject: { _ in .init(.init(systemName: "car")) },
                config: config
            )
        )
    }
}

extension FlowComposer {
    
    typealias UtilityServicePaymentFlowView = UtilityServicePaymentFlowStateWrapperView<Icon, UtilityPaymentOperatorPickerStateWrapperView<Icon>, UtilityServicePicker<Icon, UIPrimitives.AsyncImage>>
}

private extension UtilityServicePaymentFlowViewModel {
    
    static func make<Icon>(
        initialState: UtilityServicePaymentFlowState<Icon>,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> UtilityServicePaymentFlowViewModel<Icon> {
        
        let reducer = UtilityServicePaymentFlowReducer<Icon>()
        let effectHandler = UtilityServicePaymentFlowEffectHandler<Icon>()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

private extension UtilityPaymentOperatorPickerViewModel {
    
    static func make<Icon>(
        initialState: UtilityPaymentOperatorPickerState<Icon>,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> UtilityPaymentOperatorPickerViewModel<Icon> {
        
        let reducer = UtilityPaymentOperatorPickerReducer<Icon>()
        let effectHandler = UtilityPaymentOperatorPickerEffectHandler<Icon>()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

private extension UtilityServicePaymentFlowFactory
where OperatorPicker == UtilityPaymentOperatorPickerStateWrapperView<Icon>,
      ServicePicker == UtilityServicePicker<Icon, UIPrimitives.AsyncImage> {
    
    static func make(
        initialState state: OperatorPickerState,
        makeImageSubject: @escaping MakeImageSubject,
        config: UtilityPaymentConfig,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> Self {
        
        return .init(
            asyncImage: asyncImage,
            makeOperatorPicker: _makeOperatorPicker,
            makeServicePicker: _makeServicePicker
        )
        
        func asyncImage(
            icon: Icon
        ) -> UIPrimitives.AsyncImage {
            
            let imageSubject = makeImageSubject(icon)
            
            return .init(
                image: imageSubject.value,
                publisher: imageSubject.eraseToAnyPublisher()
            )
        }
        
        func _makeOperatorPicker(
            event: @escaping (OperatorPickerState.Operator) -> Void
        ) -> OperatorPicker {
            
            UtilityPaymentOperatorPickerStateWrapperView<Icon>(
                viewModel: .make(
                    initialState: state,
                    scheduler: scheduler
                ),
                config: config.operatorPicker
            )
        }
        
        func _makeServicePicker(
            state: ServicePickerState,
            event: @escaping (Service) -> Void
        ) -> ServicePicker {
            
            UtilityServicePicker(
                state: state,
                event: event,
                config: config.servicePicker,
                iconView: asyncImage(icon:)
            )
        }
    }
    
    typealias ImageSubject = CurrentValueSubject<Image, Never>
    typealias MakeImageSubject = (Icon) -> ImageSubject
}
