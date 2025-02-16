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
                    
                    // TODO: Use AttributedString to connect to URL
                    makeCheckBoxView(
                        title: "Включить переводы через СБП, принять условия обслуживания",
                        isChecked: state.termsCheck,
                        toggle: { event(.termsToggle) }
                    )
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
    
    // TODO: - add/extract config
    @inlinable
    func makeCheckBoxView(
        title: AttributedString,
        isChecked: Bool,
        toggle: @escaping () -> Void
    ) -> some View {
        
        HStack {
            
            PaymentsCheckView.CheckBoxView(
                isChecked: isChecked,
                activeColor: .systemColorActive
            )
            .onTapGesture(perform: toggle)
            
            // TODO: Use AttributedString to connect to URL
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.textBodyMR14200())
                .foregroundColor(.textPlaceholder)
        }
        .animation(.easeInOut, value: isChecked)
    }
    
    @inlinable
    func c2gPaymentFlowView(
        flow: C2GPaymentDomain.Flow,
        dismiss: @escaping () -> Void,
        successView: @escaping (C2GPaymentDomain.Navigation.Cover<C2GPaymentDomain.Navigation.PaymentSuccess>) -> some View
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
    typealias PaymentSuccess = C2GPaymentDomain.Navigation.PaymentSuccess
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
    
    var cover: Cover<C2GPaymentDomain.Navigation.PaymentSuccess>? {
        
        guard case let .success(success) = self else { return nil }
        
        return .init(id: .init(), success: success)
    }
    
    struct Cover<Success>: Identifiable {
        
        let id: UUID
        let success: Success
    }
}
