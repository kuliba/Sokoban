//
//  ViewComponents+makeSearchByUINView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import PaymentComponents
import RxViewModel
import SwiftUI
import TextFieldDomain

extension ViewComponents {
    
    @inlinable
    func goToMain() {
        
        rootEvent(.outside(.tab(.main)))
    }
    
    @inlinable
    func makeSearchByUINView(
        binder: SearchByUINDomain.Binder,
        dismiss: @escaping () -> Void,
        scanQR: @escaping () -> Void
    ) -> some View {
        
        makeSearchByUINContentView(binder)
            .background(searchByUINFlowView(flow: binder.flow))
            .navigationBar(with: navBarModelWithQR(
                title: "Поиск по УИН",
                subtitle: "Поиск начислений по УИН",
                dismiss: dismiss,
                scanQR: scanQR
            ))
            .disablingLoading(flow: binder.flow)
    }
    
    @inlinable
    func makeSearchByUINContentView(
        _ binder: SearchByUINDomain.Binder
    ) -> some View {
        
        RxWrapperView(model: binder.content) { state, event in
            
            VStack(spacing: 20) {
                
                TextInputView(
                    state: state,
                    event: event,
                    config: .iVortex(keyboard: .number, title: "УИН"),
                    iconView: {
                        
                        Image.ic24FileHash
                            .foregroundColor(.iconGray)
                    }
                )
                .keyboardType(.numberPad)
                .paddedRoundedBackground()
                
                Spacer()
                
                StatefulButtonView(
                    isActive: state.isContinueActive,
                    event: {
                        
                        binder.flow.event(.select(.uin(.init(value: binder.content.value))))
                    },
                    config: .iVortex(title: "Продолжить")
                )
                
                Image.ic72Sbp
                    .renderingMode(.original)
            }
            .padding([.horizontal, .top])
        }
    }
    
    @inlinable
    func searchByUINFlowView(
        flow: SearchByUINDomain.Flow
    ) -> some View {
        
        searchByUINFlowView(flow: flow) {
            
            c2gPaymentFlowView(
                flow: $0,
                dismiss: { flow.event(.dismiss) }
            ) { cover in
                
                makeC2GPaymentCompleteView(
                    cover: cover,
                    goToMain: goToMain
                )
            }
        }
    }

    @inlinable
    func searchByUINFlowView(
        flow: SearchByUINDomain.Flow,
        c2gPaymentFlowView: @escaping (C2GPaymentDomain.Flow) -> some View
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            SearchByUINFlowView(
                state: state.navigation,
                dismiss: { event(.dismiss) },
                destinationView: { destination in
                    
                    destinationView(
                        destination: destination,
                        dismiss: { event(.dismiss) },
                        c2gPaymentFlowView: c2gPaymentFlowView
                    )
                }
            )
        }
    }
    
    @inlinable
    @ViewBuilder
    func destinationView(
        destination: SearchByUINDomain.Navigation.Destination,
        dismiss: @escaping () -> Void,
        c2gPaymentFlowView: @escaping (C2GPaymentDomain.Flow) -> some View
    ) -> some View {
        
        switch destination {
        case let .c2gPayment(binder):
            makeC2GPaymentView(
                binder: binder,
                dismiss: dismiss,
                c2gPaymentFlowView: c2gPaymentFlowView
            )
        }
    }
}

extension SearchByUINDomain.Content {
    
    var value: String { state.uinInputState.value }
}

private extension TextInputState {
    
    var isContinueActive: Bool  {
        
        uinInputState.isValid && !uinInputState.isEditing
    }
    
    var uinInputState: UINInputState {
        
        return .init(
            isEditing: textField.isEditing,
            isValid: message == nil && !textField.text.isNilOrEmpty,
            value: textField.text ?? ""
        )
    }
}

struct UINInputState: Equatable {
    
    var isEditing = false
    var isValid = false
    var value = ""
}

private extension TextFieldState {
    
    var isEditing: Bool {
        
        switch self {
        case .editing: return true
        default:       return false
        }
    }
}

struct SearchByUINFlowView<DestinationView: View>: View {
    
    let state: State?
    let dismiss: () -> Void
    let destinationView: (SearchByUINDomain.Navigation.Destination) -> DestinationView
    
    var body: some View {
        
        Color.clear
            .alert(item: state?.backendFailure, content: alert)
            .navigationDestination(
                destination: state?.destination,
                content: destinationView
            )
    }
}

extension SearchByUINFlowView {
    
    typealias State = SearchByUINDomain.Navigation
}

private extension SearchByUINFlowView {
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert(action: dismiss)
    }
}

extension SearchByUINDomain.Navigation {
    
    var backendFailure: BackendFailure? {
        
        guard case let .failure(backendFailure) = self else { return nil }
        
        return backendFailure
    }
    
    var destination: Destination? {
        
        guard case let .payment(c2gPayment) = self else { return nil }
        
        return .c2gPayment(c2gPayment)
    }
    
    enum Destination {
        
        case c2gPayment(C2GPayment)
    }
}

extension SearchByUINDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .c2gPayment(c2gPayment):
            return .c2gPayment
        }
    }
    
    enum ID: Hashable { // TODO: improve with ObjectIdentifier
        
        case c2gPayment
    }
}
