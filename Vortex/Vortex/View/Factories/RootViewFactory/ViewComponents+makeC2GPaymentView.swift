//
//  ViewComponents+makeC2GPaymentView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentView(
        _ binder: C2GPaymentDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 16) {
            
            Text("TBD: C2G Payment")
                .font(.headline)
            
            Button("connectivityFailure") {
                
                binder.flow.event(.select(.pay("connectivityFailure")))
            }
            
            Button("serverFailure") {
                
                binder.flow.event(.select(.pay("serverFailure")))
            }
            
            Button("success") {
                
                binder.flow.event(.select(.pay(UUID().uuidString)))
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.bordered)
        .navigationBarWithBack(title: "Оплата", dismiss: dismiss)
        .background(c2gPaymentFlowView(flow: binder.flow, dismiss: dismiss))
        .disablingLoading(flow: binder.flow)
    }
    
    @inlinable
    func c2gPaymentFlowView(
        flow: C2GPaymentDomain.Flow,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            C2GPaymentFlowView(
                state: state.navigation,
                dismiss: dismiss
            )
        }
    }
}

struct C2GPaymentFlowView: View {
    
    let state: State?
    let dismiss: () -> Void
    
    var body: some View {
        
        Color.clear
            .alert(item: state?.backendFailure, content: alert)
    }
}

extension C2GPaymentFlowView {
    
    typealias State = C2GPaymentDomain.Navigation
}

private extension C2GPaymentFlowView {
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert(action: dismiss)
    }
}

extension C2GPaymentDomain.Navigation {
    
    var backendFailure: BackendFailure? {
        
        guard case let .failure(backendFailure) = self else { return nil }
        
        return backendFailure
    }
}
