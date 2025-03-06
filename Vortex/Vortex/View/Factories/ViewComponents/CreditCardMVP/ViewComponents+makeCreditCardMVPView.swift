//
//  ViewComponents+makeCreditCardMVPView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import ButtonComponent
import PaymentCompletionUI
import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeCreditCardMVPView(
        binder: CreditCardMVPDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        makeCreditCardMVPContentView(binder)
            .background(makeCreditCardMVPFlowView(binder.flow))
            .navigationBarWithBack(
                title: "Кредитная карта",
                subtitle: "Всё включено",
                subtitleForegroundColor: .textPlaceholder,
                dismiss: dismiss
            )
            .disablingLoading(flow: binder.flow)
    }
    
    @inlinable
    func makeCreditCardMVPContentView(
        _ binder: CreditCardMVPDomain.Binder
    ) -> some View {
        
        RxWrapperView(model: binder.content) { state, event in
            
            makeCreditCardMVPContentView(state, event) {
                
                binder.flow.event(.select(
                    .order(.init(otp: state.otp))
                ))
            }
        }
    }
    
    @inlinable
    func makeCreditCardMVPContentView(
        _ state: CreditCardMVPDomain.State,
        _ event: @escaping (CreditCardMVPDomain.Event) -> Void,
        _ order: @escaping () -> Void
    ) -> some View {
        
        VStack(spacing: 32) {
            
            HStack {
                
                Button("success") { event(.otp("000000")) }
                Divider()
                Button("failure") { event(.otp("111111")) }
                Divider()
                Button("otp mismatch") { event(.otp("222222")) }
            }
            .frame(height: 48)
            
            Text("OTP: \(state.otp)")
                .font(.headline)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            
            StatefulButtonView(
                isActive: state.isValid,
                event: order,
                config: .iVortex(title: "Отправить заявку")
            )
            .padding(.bottom, 8)
        }
        .padding([.horizontal, .top])
        .conditionalBottomPadding(12)
    }
    
    @inlinable
    func makeCreditCardMVPFlowView(
        _ flow: CreditCardMVPDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            Color.clear
                .fullScreenCover(cover: state.navigation?.cover) { cover in
                    
                    // TODO: add status subtitle
                    makePaymentCompletionLayoutView(
                        state: cover.state,
                        details: {
                            
                            cover.message.text(
                                withConfig: .placeholder,
                                alignment: .center
                            )
                        },
                        statusConfig: .creditCardMVP
                    )
                }
        }
    }
}

// MARK: - UI Mapping

private extension CreditCardMVPDomain.Navigation {
    
    var cover: Complete? {
        
        switch self {
        case let .complete(complete):
            complete
        }
    }
}

// MARK: - Adapters

private extension CreditCardMVPDomain.Navigation.Complete {
    
    var state: PaymentCompletion {
        
        return .init(formattedAmount: nil, merchantIcon: nil, status: status)
    }
}
