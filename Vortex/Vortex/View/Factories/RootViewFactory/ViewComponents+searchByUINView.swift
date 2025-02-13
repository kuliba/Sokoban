//
//  ViewComponents+searchByUINView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
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
        .frame(maxHeight: .infinity, alignment: .center)
        .background(searchByUINFlowView(flow: binder.flow))
    }
    
    func searchByUINFlowView(
        flow: SearchByUINDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, event in
            
            SearchByUINFlowView(
                state: state.navigation,
                dismiss: { flow.event(.dismiss) }
            )
        }
    }
}

struct SearchByUINFlowView: View {
    
    let state: State?
    let dismiss: () -> Void
    
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
    
    @ViewBuilder
    func destinationView(
        destination: SearchByUINDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .c2gPayment(c2gPayment):
            // TODO: extract to components
            Text("TBD c2gPayment:" + String(describing: c2gPayment))
                .frame(maxHeight: .infinity, alignment: .top)
                .navigationBarWithBack(title: "Оплата", dismiss: dismiss)
        }
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
