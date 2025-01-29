//
//  RootViewFactory+makeCategoryPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.01.2025.
//

import RxViewModel
import SwiftUI
import UIPrimitives

extension RootViewFactory {
    
    func makeCategoryPickerView(
        _ binder: CategoryPickerViewDomain.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: { state, _ in
                
                makeCategoryPickerContentView(
                    binder.content,
                    select: { binder.flow.event(.select(.category($0))) },
                    headerHeight: nil
                )
                .alert(
                    item: state.failure,
                    content: makeAlert(binder: binder)
                )
                .navigationDestination(
                    destination: makeDestination(state),
                    content: {
                        
                        makeDestinationView(destination: $0) {
                            
                            binder.flow.event(.dismiss)
                        }
                    }
                )
            }
        )
    }
    
    private func makeDestination(
        _ state: CategoryPickerViewDomain.FlowDomain.State
    ) -> CategoryPickerViewDomain.Destination? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
    
    @ViewBuilder
    private func makeDestinationView(
        destination: CategoryPickerViewDomain.Destination,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case let .mobile(paymentsViewModel):
            components.makePaymentsView(paymentsViewModel)
            
        case let .standard(standard):
            switch standard.model {
            case let .failure(binder):
                components.serviceCategoryFailureView(binder: binder)
                
            case let .success(binder):
                makePaymentProviderPickerView(binder)
            }
            
        case let .taxAndStateServices(paymentsViewModel):
            components.makePaymentsView(paymentsViewModel)
            
        case let .transport(transport):
            transportPaymentsView(transport)
        }
    }
    
    private func makeAlert(
        binder: CategoryPickerViewDomain.Binder
    ) -> (SelectedCategoryFailure) -> Alert {
        
        return { failure in
            
            return .init(
                with: .error(message: failure.message, event: .dismiss),
                event: { binder.flow.event($0) }
            )
        }
    }
}

// MARK: - Adapters

private extension AlertModelOf<CategoryPickerViewDomain.FlowDomain.Event> {
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .default(
            title: message != .errorRequestLimitExceeded ? "Ошибка" : "",
            message: message,
            primaryEvent: event
        )
    }
    
    private static func `default`(
        title: String,
        message: String?,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent? = nil
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: secondaryEvent.map {
                
                .init(
                    type: .cancel,
                    title: "Отмена",
                    event: $0
                )
            }
        )
    }
}

private extension CategoryPickerViewDomain.FlowDomain.State {
    
    var failure: SelectedCategoryFailure? {
        
        guard case let .failure(failure) = navigation
        else { return nil }
        
        return failure
    }
}

extension CategoryPickerViewDomain.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
            
        case let .mobile(mobile):
            return .init(mobile)
            
        case let .standard(standard):
            switch standard.model {
            case let .failure(failure):
                return .init(failure)
                
            case let .success(success):
                return .init(success)
            }
            
        case let .taxAndStateServices(taxAndStateServices):
            return .init(taxAndStateServices)
            
        case let .transport(transport):
            return .init(transport)
        }
    }
}
