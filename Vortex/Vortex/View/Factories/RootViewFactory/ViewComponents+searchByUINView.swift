//
//  ViewComponents+searchByUINView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func searchByUINView(
        _ binder: SearchByUINDomain.Binder
    ) -> some View {
        
        VStack(spacing: 16) {
            
            Text("TBD: Search by UIN")
                .font(.headline)
            
            Button("connectivityFailure") {
                
                binder.flow.event(.select(.uin(.init(value: "connectivityFailure"))))
            }
            
            Button("serverFailure") {
                
                binder.flow.event(.select(.uin(.init(value: "serverFailure"))))
            }
            
            Button("success") {
                
                binder.flow.event(.select(.uin(.init(value: UUID().uuidString))))
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.bordered)
        .background(searchByUINFlowView(flow: binder.flow))
    }
    
    @inlinable
    func searchByUINFlowView(
        flow: SearchByUINDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            SearchByUINFlowView(
                state: state.navigation,
                dismiss: { flow.event(.dismiss) },
                destinationView: {
                    
                    destinationView(destination: $0) { flow.event(.dismiss) }
                }
            )
        }
    }
    
    @inlinable
    @ViewBuilder
    func destinationView(
        destination: SearchByUINDomain.Navigation.Destination,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case let .c2gPayment(binder):
            makeC2GPaymentView(binder, dismiss: dismiss)
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
