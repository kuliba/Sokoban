//
//  ViewComponents+makeCreditCardMVPView.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import ButtonComponent
import CreditCardMVPUI
import PaymentCompletionUI
import PaymentComponents
import RxViewModel
import SwiftUI

extension ViewComponents {
    
    @inlinable
    func makeCreditCardMVPView(
        binder: CreditCardMVPDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        ZStack(alignment: .top) {
            
            makeCreditCardMVPContentView(binder)
            makeInformerView(binder.flow)
        }
        .background(makeCreditCardMVPFlowView(binder.flow, dismiss: dismiss))
        .navigationBarWithBack( // TODO: switch to dynamic scroll observing navbar
            title: "Кредитная карта",
            subtitle: "Всё включено",
            subtitleForegroundColor: .textPlaceholder,
            dismiss: dismiss
        )
        .disablingLoading(flow: binder.flow)
    }
    
    @inlinable
    func makeInformerView(
        _ flow: CreditCardMVPDomain.Flow
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            state.navigation?.informer.map(InformerView.init(viewModel:))
                .padding(.top, 8)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeCreditCardMVPContentView(
        _ binder: CreditCardMVPDomain.Binder
    ) -> some View {
        
        let product = ProductCard(limit: "₽ 0", md5Hash: "d65188320fca0a9291240dae108ebd73", options: [.init(title: "!Fee", value: "!Free"), .init(title: "!Where", value: "!Everywhere")], title: "Credit Card", subtitle: "Better forever")
        let consent = AttributedString(("Я соглашаюсь с Условиями и Тарифами"), tariffURL: .init(string: "https://ya.ru")!, conditionURL: .init(string: "https://ya.ru")!)
        
        List {
            
            Text("Mock backend response")
                .font(.title.bold())
            
            Button("Alert Failure") {
                
                binder.flow.event(.select(.alert("fail to fetch data")))
            }
            
            Button("Informer Failure") {
                
                binder.flow.event(.select(.informer("fail to fetch data")))
            }
            
            Button("Application Failure") {
                
                binder.flow.event(.select(.failure))
            }
            
            Button("Application In Review") {
                
                binder.flow.event(.select(.inReview))
            }
            
            Button("Application Approved") {
                
                binder.flow.event(.select(.approved(consent: consent, product)))
            }
            
            Button("Application Rejected") {
                
                binder.flow.event(.select(.rejected))
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Flow
    
    @inlinable
    func makeCreditCardMVPFlowView(
        _ flow: CreditCardMVPDomain.Flow,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            CreditCardMVPFlowView(
                state: state.navigation,
                dismiss: dismiss,
                completeView: makeCompleteView,
                decisionView: makeDecisionView
            )
        }
    }
    
    @inlinable
    func makeCompleteView(
        _ complete: CreditCardMVPDomain.Navigation.Complete
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: complete.state,
            details: {
                
                complete.message.text(
                    withConfig: .placeholder,
                    alignment: .center
                )
            },
            statusConfig: .creditCardMVP(rejectedTitle: .failure)
        )
    }
    
    @inlinable
    @ViewBuilder
    func makeDecisionView(
        _ decision: CreditCardMVPDomain.Navigation.Decision
    ) -> some View {
        
        switch decision.status {
        case let .approved(approved):
            makeDecisionApprovedView(
                message: decision.message,
                title: decision.title,
                approved: approved
            )
            
        case .rejected:
            makeDecisionRejectedView(
                message: decision.message,
                title: decision.title
            )
        }
    }
    
    @inlinable
    func makeDecisionApprovedView(
        message: String,
        title: String,
        approved: CreditCardMVPDomain.Navigation.Decision.Status.Approved
    ) -> some View {
        
        VStack(spacing: 23) {
            
            ProductCardView(
                product: approved.product,
                config: .prod(),
                iconView: makeIconView
            )
            
            message.text(withConfig: .init(
                textFont: .textH3Sb18240(),
                textColor: .textSecondary
            ))
            .frame(maxWidth: .infinity, alignment: .leading) // ??
            
            approved.info.text(withConfig: .init(
                textFont: .textBodyMR14200(),
                textColor: .textSecondary
            ))
            .frame(maxWidth: .infinity, alignment: .leading) // ??
            
            makeCheckBoxView(title: approved.consent, isChecked: true, toggle: {})
            
            Spacer()
            
            goToMainHeroButton()
        }
        .padding([.horizontal, .top])
        .navigationBar(withTitle: title)
    }
    
    @inlinable
    func makeDecisionRejectedView(
        message: String,
        title: String
    ) -> some View {
        
        makePaymentCompletionLayoutView(
            state: .init(formattedAmount: nil, merchantIcon: nil, status: .rejected),
            details: {
                
                message.text(
                    withConfig: .placeholder,
                    alignment: .center
                )
            },
            statusConfig: .creditCardMVP(rejectedTitle: .rejected)
        )
    }
}

// MARK: - Flow View

struct CreditCardMVPFlowView<CompleteView, DecisionView>: View
where CompleteView: View,
      DecisionView: View {
    
    let state: State?
    let dismiss: () -> Void
    let completeView: (State.Complete) -> CompleteView
    let decisionView: (State.Decision) -> DecisionView
    
    var body: some View {
        
        Color.clear
            .alert(item: state?.alert, content: alert)
            .fullScreenCover(cover: state?.cover, content: coverView)
    }
}

extension CreditCardMVPFlowView {
    
    typealias State = CreditCardMVPDomain.Navigation
}

private extension CreditCardMVPFlowView {
    
    func alert(
        backendFailure: BackendFailure
    ) -> Alert {
        
        return backendFailure.alert(title: "Ошибка", action: dismiss)
    }
    
    @ViewBuilder
    func coverView(
        cover: State.Cover
    ) -> some View {
        
        switch cover {
        case let .complete(complete):
            completeView(complete)
            
        case let .decision(decision):
            decisionView(decision)
        }
    }
}

// MARK: - UI Mapping

private extension CreditCardMVPDomain.Navigation {
    
    var alert: BackendFailure? {
        
        guard case let .alert(message) = self else { return nil }
        return .connectivity(message)
    }
    
    var cover: Cover? {
        
        switch self {
        case .alert, .informer:
            return nil
            
        case let .complete(complete):
            return .complete(complete)
            
        case let .decision(decision):
            return .decision(decision)
        }
    }
    
    enum Cover {
        
        case complete(Complete)
        case decision(Decision)
    }
    
    var informer: InformerView.InformerItemViewModel? {
        
        guard case let .informer(message) = self else { return nil }
        return .init(message: message, icon: .ic24Close)
    }
}

extension CreditCardMVPDomain.Navigation.Cover: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .complete(complete):
            return .complete(complete.status)
            
        case let .decision(decision):
            switch decision.status {
            case .approved: return .decision(.approved)
            case .rejected: return .decision(.rejected)
            }
        }
    }
    
    enum ID: Hashable {
        
        case complete(CompleteStatus)
        case decision(DecisionStatus)
        
        typealias CompleteStatus = CreditCardMVPDomain.Navigation.Complete.Status
        
        enum DecisionStatus {
            
            case approved, rejected
        }
    }
}

// MARK: - Adapters

private extension CreditCardMVPDomain.Navigation.Complete {
    
    var state: PaymentCompletion {
        
        return .init(formattedAmount: nil, merchantIcon: nil, status: .init(status))
    }
}

private extension PaymentCompletion.Status {
    
    init(_ status: CreditCardMVPDomain.Navigation.Complete.Status) {
        
        switch status {
        case .failure:  self = .rejected
        case .inReview: self = .completed
        }
    }
}

// MARK: - Helpers

extension AttributedString {
    
    init(
        _ consent: String,
        tariffURL: URL,
        conditionURL: URL
    ) {
        var attributedString = AttributedString(consent)
        attributedString.foregroundColor = .textPlaceholder
        attributedString.font = .textBodySR12160()
        
        if let tariff = attributedString.range(of: "Тарифами") {
            attributedString[tariff].link = tariffURL
            attributedString[tariff].underlineStyle = .single
            attributedString[tariff].foregroundColor = .textPlaceholder
        }
        
        if let tariff = attributedString.range(of: "Условиями") {
            attributedString[tariff].link = conditionURL
            attributedString[tariff].underlineStyle = .single
            attributedString[tariff].foregroundColor = .textPlaceholder
        }
        
        self = attributedString
    }
}

// MARK: - Constants

private extension String {
    
    static let failure = "Заявка на выпуск\nкарты неуспешна"
    static let rejected = "Кредитная карта не одобрена"
}
