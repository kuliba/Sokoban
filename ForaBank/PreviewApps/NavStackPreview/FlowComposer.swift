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
    
    typealias OperatorPicker = UtilityPaymentOperatorPickerStateWrapperView<Icon, UtilityPaymentOperatorPickerFooterView, LastPaymentsView<Icon>, OperatorsView<Icon>>
    typealias ServicePicker = UtilityServicePicker<Icon, UIPrimitives.AsyncImage>
    typealias UtilityServicePaymentFlowView = UtilityServicePaymentFlowStateWrapperView<Icon, OperatorPicker, ServicePicker>
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
where OperatorPicker == UtilityPaymentOperatorPickerStateWrapperView<Icon, UtilityPaymentOperatorPickerFooterView, LastPaymentsView<Icon>, OperatorsView<Icon>>,
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
            event: @escaping (OperatorPickerEvent) -> Void
        ) -> OperatorPicker {
            
            .init(
                viewModel: .make(
                    initialState: state,
                    scheduler: scheduler
                ),
                factory: makeFactory(
                    event: event,
                    config: config.operatorPicker
                )
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
    
    static func makeFactory(
        event: @escaping (OperatorPickerEvent) -> Void,
        config: UtilityPaymentOperatorPickerConfig
    ) -> OperatorPickerFactory {
        
        return .init(
            footerView: footerView,
            lastPaymentsView: lastPaymentsView,
            operatorsView: operatorsView
        )
        
        func footerView(
            _ state: Bool
        ) -> UtilityPaymentOperatorPickerFooterView {
            
            .init(
                state: state,
                event: {
                    switch $0 {
                    case .addCompany:
                        event(.addCompany)
                        
                    case .payByInstructions:
                        event(.payByInstructions)
                    }
                },
                config: config.footer
            )
        }
        
        func lastPaymentsView(
            lastPayments: [State.LastPayment]
        ) -> LastPaymentsView<Icon> {
            
            .init(
                state: lastPayments,
                event: { event(.select(.lastPayment($0))) },
                config: config.lastPayments
            )
        }
        
        func operatorsView(
            operators: [State.Operator]
        ) -> OperatorsView<Icon> {
            
            .init(
                state: operators,
                event: { event(.select(.operator($0))) },
                config: config.operatorsPicker
            )
        }
        
        typealias State = UtilityPaymentOperatorPickerState<Icon>
        typealias Event = UtilityPaymentOperatorPickerEvent<Icon>
        typealias Config = UtilityPaymentOperatorPickerConfig
    }
    
    typealias ImageSubject = CurrentValueSubject<Image, Never>
    typealias MakeImageSubject = (Icon) -> ImageSubject
  
    typealias OperatorPickerEvent = UtilityPaymentOperatorPickerEvent<Icon>
    typealias OperatorPickerFactory = UtilityPaymentOperatorPickerLayoutFactory<Icon, UtilityPaymentOperatorPickerFooterView, LastPaymentsView<Icon>, OperatorsView<Icon>>
}
