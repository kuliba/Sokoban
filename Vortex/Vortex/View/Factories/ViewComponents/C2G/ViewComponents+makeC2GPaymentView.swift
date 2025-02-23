//
//  ViewComponents+makeC2GPaymentView.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GCore
import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeC2GPaymentView(
        binder: C2GPaymentDomain.Binder,
        dismiss: @escaping () -> Void,
        c2gPaymentFlowView: @escaping (C2GPaymentDomain.Flow) -> some View
    ) -> some View {
        
        makeC2GPaymentContentView(content: binder.content) {
            
            binder.flow.event(.select(.pay($0)))
        }
        .navigationBarWithBack(title: "Оплата", dismiss: dismiss)
        .background(c2gPaymentFlowView(binder.flow))
        .disablingLoading(flow: binder.flow)
    }
    
    @inlinable
    func makeC2GPaymentContentView(
        content: C2GPaymentDomain.Content,
        pay: @escaping (C2GPaymentDigest) -> Void
    ) -> some View {
        
        RxWrapperView(model: content) { state, event in
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 16) {
                    
                    makeProductSelectView(
                        state: state.productSelect,
                        event: { event(.productSelect($0)) }
                    )
                    
                    state.termsCheck.map {
                        
                        makeCheckBoxView(
                            title: state.context.term,
                            isChecked: $0,
                            toggle: { event(.termsToggle) }
                        )
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                
                makeSPBFooter(isActive: state.digest != nil) {
                    
                    state.digest.map(pay)
                }
            }
        }
        .padding()
    }
        
    @inlinable
    func c2gPaymentFlowView(
        flow: C2GPaymentDomain.Flow,
        dismiss: @escaping () -> Void,
        successView: @escaping (C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Complete>) -> some View
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            C2GPaymentFlowView(
                state: state.navigation,
                dismiss: dismiss,
                successView: successView
            )
        }
    }
}

struct C2GPaymentFlowView<SuccessView: View>: View {
    
    let state: State?
    let dismiss: () -> Void
    let successView: (Cover) -> SuccessView
    
    var body: some View {
        
        Color.clear
            .alert(item: state?.backendFailure, content: alert)
            .fullScreenCover(cover: state?.cover, content: successView)
    }
}

extension C2GPaymentFlowView {
    
    typealias State = C2GPaymentDomain.Navigation
    typealias PaymentSuccess = C2GPaymentDomain.Complete
    typealias Cover = C2GPaymentDomain.Navigation.Cover<PaymentSuccess>
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
    
    var cover: Cover<C2GPaymentDomain.Complete>? {
        
        guard case let .success(content) = self else { return nil }
        
        return .init(id: .init(), content: content)
    }
    
    struct Cover<Content>: Identifiable {
        
        let id: UUID
        let content: Content
    }
}
