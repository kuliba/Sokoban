//
//  ViewComponents+makeCategoryPickerSectionView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI
import UIPrimitives

extension ViewComponents {
    
    @ViewBuilder
    func makeCategoryPickerSectionView(
        _ categoryPicker: any CategoryPicker
    ) -> some View {
        
        if let binder = categoryPicker.sectionBinder {
            
            RxWrapperView(model: binder.flow) { state, _ in
                
                makeCategoryPickerContentView(
                    binder.content,
                    select: { binder.flow.event(.select(.category($0))) },
                    headerHeight: 24
                )
                .disabled(state.isLoading)
                .alert(
                    item: state.failure,
                    content: makeAlert(binder: binder)
                )
                .navigationDestination(
                    destination: makeSectionDestination(state),
                    content: {
                        
                        makeSectionDestinationView(
                            destination: $0,
                            dismiss: { binder.flow.event(.dismiss) },
                            scanQR: { binder.flow.event(.select(.qr)) }
                        )
                    }
                )
            }
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
        destination: CategoryPickerSectionDomain.Destination,
        dismiss: @escaping () -> Void,
        scanQR: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case let .mobile(paymentsViewModel):
            makePaymentsView(paymentsViewModel)
            
        case let .taxAndStateServices(tax):
            switch tax {
            case let .legacy(paymentsViewModel):
                makePaymentsView(paymentsViewModel)
                
            case let .v1(node):
                // TODO: extract
                RxWrapperView(model: node.model.flow) { state, event in
                    
                    makePaymentsView(node.model.content, isRounded: true)
                        .navigationBarHidden(true)
                        .navigationBarWithBack(
                            title: "TBD: + QR button",
                            dismiss: dismiss
                        )
                        .navigationLink(
                            value: state.navigation,
                            dismiss: { event(.dismiss) },
                            content: {
                            
                                switch $0 {
                                case let .searchByUIN(searchByUIN):
                                    makeSearchByUINView(
                                        binder: searchByUIN,
                                        dismiss: { event(.dismiss) },
                                        scanQR: { rootEvent(.scanQR) }
                                    )
                                }
                            }
                        )
                }
            }
            
        case let .transport(transport):
            transportPaymentsView(transport)
                .navigationBarWithBack(
                    title: "Транспорт",
                    dismiss: dismiss,
                    rightItem: .barcodeScanner(action: scanQR)
                )
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
            
        case let .taxAndStateServices(tax):
            switch tax {
            case let .legacy(paymentsViewModel):
                return .init(paymentsViewModel)
                
            case let .v1(node):
                return .init(node.model)
            }
            
        case let .transport(transport):
            return .init(transport)
        }
    }
}
