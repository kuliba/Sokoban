//
//  ViewComponents+makeCreditCardMVPView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeCreditCardMVPView(
        binder: CreditCardMVPDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        makeCreditCardMVPContentView(binder)
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
        
        VStack {
            
            Text("6x0 = success\n6x1 = failure\n6x2 = otp mismatch")
                .foregroundStyle(.secondary)
            
            HStack {
                
                Button("success") { event(.otp("000000")) }
                Button("failure") { event(.otp("111111")) }
                Button("otp mismatch") { event(.otp("222222")) }
            }
            
            TextField(
                "OTP",
                text: .init(
                    get: { state.otp },
                    set: { event(.otp($0)) }
                )
            )
            .keyboardType(.numberPad)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding([.horizontal, .top])
        .safeAreaInset(edge: .bottom) {
            
            // TODO: title depends on state (if otp present)
            heroButton(title: "Отправить заявку", action: order)
                .padding(.bottom, 8)
        }
        .conditionalBottomPadding(12)
    }
}
