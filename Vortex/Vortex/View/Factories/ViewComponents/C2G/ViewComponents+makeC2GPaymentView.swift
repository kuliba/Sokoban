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
                
                // TODO: extract sub-components
                VStack(spacing: 16) {
                    
                    Group {
                        
                        state.context.merchantNameField.map(infoView)
                        
                        VStack(spacing: 13) {
                            
                            infoView(state.context.uinField)
                            
                            state.context.purposeField.map { purposeField in
                                
                                VStack(spacing: 13) {
                                    
                                    Divider()
                                    infoView(purposeField)
                                }
                            }
                        }
                        
                        VStack(spacing: 13) {
                            
                            state.context.dateNField.map(infoView)
                            
                            if state.context.dateNField != nil && state.context.paymentTermField != nil {
                             
                                Divider()
                            }
                            
                            state.context.paymentTermField.map(infoView)
                        }
                        
                        state.context.legalActField.map(infoView)
                    }
                    .paddedRoundedBackground(edgeInsets: .default2)
                    
                    makeProductSelectView(
                        state: state.productSelect,
                        event: { event(.productSelect($0)) }
                    )
                    
                    amountView(state.context)
                    
                    state.termsCheck.map {
                        
                        makeCheckBoxView(
                            title: state.context.term,
                            isChecked: $0,
                            toggle: { event(.termsToggle) }
                        )
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
            .safeAreaInset(edge: .bottom) {
                
                makeSPBFooter(isActive: state.digest != nil) {
                    
                    state.digest.map(pay)
                }
                .padding(.horizontal)
                .background(.white)
            }
        }
    }
    
    @inlinable
    func amountView(
        _ context: C2GPaymentDomain.Context
    ) -> some View {
        
        VStack(spacing: 12) {
            
            context.formattedAmountField.map(infoViewCompressed)
            context.discountField.map(infoViewCompressed)
            context.discountExpiryField.map(infoViewCompressed)
        }
        .paddedRoundedBackground(edgeInsets: .default2)
    }
    
    @inlinable
    func infoViewCompressed(
        _ field: C2GPaymentDomain.Context.Field
    ) -> some View {
        
        infoViewCompressed(id: field.id, title: field.title, value: field.value)
    }
    
    @inlinable
    func infoView(
        _ field: C2GPaymentDomain.Context.Field
    ) -> some View {
        
        infoView(
            id: field.id,
            icon: field.icon.map { $0.foregroundColor(.iconGray) },
            title: field.title,
            value: field.value
        )
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

// MARK: - Mapping/Adapters

extension C2GPaymentDomain.Context {
    
    struct Field: Equatable {
        
        let id: String
        let icon: Image?
        let title: String
        let value: String
        
        init(
            id: String = UUID().uuidString,
            icon: Image? = nil,
            title: String,
            value: String
        ) {
            self.id = id
            self.icon = icon
            self.title = title
            self.value = value
        }
    }
}

extension C2GPaymentDomain.Context {
    
    var dateNField: Field? {
        
        return dateN.map {
            
            return .init(icon: .ic24Calendar, title: .dateN, value: $0)
        }
    }
    
    var paymentTermField: Field? {
        
        return paymentTerm.map {
            
            return .init(icon: .ic24CalendarPayment, title: .paymentTerm, value: $0)
        }
    }
    
    var legalActField: Field? {
        
        return legalAct.map {
            
            return .init(icon: .ic24FileText, title: .legalAct, value: $0)
        }
    }
    
    var merchantNameField: Field? {
        
        return merchantName.map {
            
            return .init(icon: .ic24Bank, title: .merchantName, value: $0)
        }
    }
    
    var uinField: Field {
        
        return .init(icon: .ic24File, title: .uin, value: uin)
    }
    
    var purposeField: Field? {
        
        return purpose.map {
            
            return .init(icon: .ic24Tax, title: .purpose, value: $0)
        }
    }
    
    var formattedAmountField: Field? {
        
        return formattedAmount.map {
            
            return .init(title: .formattedAmount, value: $0)
        }
    }
    
    var discountField: Field? {
        
        return discount.map {
            
            return .init(title: .discount, value: $0)
        }
    }
    
    var discountExpiryField: Field? {
        
        return discountExpiry.map {
            
            return .init(title: .discountExpiry, value: $0)
        }
    }
}

private extension String {
    
    static let dateN: Self = "Дата начисления"
    static let discount: Self = "Скидка"
    static let discountExpiry: Self = "Срок действия скидки"
    static let formattedAmount: Self = "Сумма к оплате"
    static let legalAct: Self = "Информация о НПА"
    static let merchantName: Self = "Получатель"
    static let paymentTerm: Self = "Срок оплаты"
    static let purpose: Self = "Назначение платежа"
    static let uin: Self = "Номер документа (УИН)"
}
