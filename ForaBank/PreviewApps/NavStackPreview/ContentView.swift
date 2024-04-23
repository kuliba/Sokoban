//
//  ContentView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import Combine
import CombineSchedulers
import RxViewModel
import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    var body: some View {
        
        NavigationView {
            
            UtilityServicePaymentFlowStateWrapperView(
                viewModel: .make(initialState: .services(.preview)),
                factory: .makeFactory(
                    makeImageSubject: { _ in .init(.init(systemName: "car")) },
                    config: .preview
                )
            )
        }
    }
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
            scheduler: .main
        )
    }
}

private extension UtilityServicePaymentFlowFactory
where OperatorPicker == UtilityPaymentOperatorPickerStateWrapperView<Icon>,
      ServicePicker == UtilityServicePicker<Icon, UIPrimitives.AsyncImage> {
    
    static func makeFactory(
        makeImageSubject: @escaping MakeImageSubject,
        config: UtilityServicePickerConfig
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
        ) -> OperatorPicker {
            
            UtilityPaymentOperatorPickerStateWrapperView<Icon>()
        }
        
        func _makeServicePicker(
            state: PickerState,
            event: @escaping (Service) -> Void
        ) -> ServicePicker {
            
            UtilityServicePicker(
                state: state,
                event: event,
                config: config,
                iconView: asyncImage(icon:)
            )
        }
    }
    
    typealias ImageSubject = CurrentValueSubject<Image, Never>
    typealias MakeImageSubject = (Icon) -> ImageSubject
}

#Preview {
    ContentView()
}
