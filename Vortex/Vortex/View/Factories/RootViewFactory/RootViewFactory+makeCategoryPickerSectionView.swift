//
//  RootViewFactory+makeCategoryPickerSectionView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI
import UIPrimitives

extension RootViewFactory {
    
    @ViewBuilder
    func makeCategoryPickerSectionView(
        _ categoryPicker: any CategoryPicker
    ) -> some View {
        
        if let binder = categoryPicker.sectionBinder {
            
            RxWrapperView(
                model: binder.flow,
                makeContentView: { state, _ in
                    
                    makeCategoryPickerContentView(
                        binder.content, 
                        select: { binder.flow.event(.select($0)) },
                        headerHeight: 24
                    )
                        .alert(
                            item: state.failure,
                            content: makeAlert(binder: binder)
                        )
                        .navigationDestination(
                            destination: makeSectionDestination(state),
                            content: makeSectionDestinationView
                        )
                }
            )
            .padding(.top, 20)
            
        } else {
            
            Text("Unexpected categoryPicker type \(String(describing: categoryPicker))")
                .foregroundColor(.red)
        }
    }
    
    private func makeSectionDestination(
        _ state: CategoryPickerSectionDomain.FlowDomain.State
    ) -> CategoryPickerSectionDomain.Destination? {
        
        guard case let .destination(destination) = state.navigation
        else { return nil }
        
        return destination
    }
    
    @ViewBuilder
    private func makeSectionDestinationView(
        destination: CategoryPickerSectionDomain.Destination
    ) -> some View {
        
        switch destination {
        case let .mobile(mobile):
            components.makePaymentsView(mobile.paymentsViewModel)
            
        case let .taxAndStateServices(wrapper):
            components.makePaymentsView(wrapper.paymentsViewModel)
            
        case let .transport(transport):
            transportPaymentsView(transport)
        }
    }
    
    private func makeAlert(
        binder: CategoryPickerSectionDomain.Binder
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

private extension AlertModelOf<CategoryPickerSectionDomain.FlowDomain.Event> {
    
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

private extension CategoryPickerSectionDomain.FlowDomain.State {
    
    var failure: SelectedCategoryFailure? {
        
        guard case let .failure(failure) = navigation
        else { return nil }
        
        return failure
    }
}

extension CategoryPickerSectionDomain.Destination: Identifiable {
    
    var id: ObjectIdentifier {
        
        switch self {
            
        case let .mobile(mobile):
            return .init(mobile)
            
        case let .taxAndStateServices(taxAndStateServices):
            return .init(taxAndStateServices)
            
        case let .transport(transport):
            return .init(transport)
        }
    }
}
