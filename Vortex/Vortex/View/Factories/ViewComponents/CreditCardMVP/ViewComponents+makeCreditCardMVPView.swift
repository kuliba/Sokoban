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
    func makeCreditCardMVPContentView(
        _ binder: CreditCardMVPDomain.Binder
    ) -> some View {
        
        List {
            
            Text("Mock backend response")
                .font(.title.bold())
            
            Button("Alert Failure") {
                
                binder.flow.event(.select(.alert("fail to fetch data")))
            }
            
            Button("Informer Failure") {
                
                binder.flow.event(.select(.informer("fail to fetch data")))
            }
            
            Button("Failure") {
                
                binder.flow.event(.select(.failure))
            }
        }
        .listStyle(.plain)
    }
    
    @inlinable
    func makeCreditCardMVPFlowView(
        _ flow: CreditCardMVPDomain.Flow,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        RxWrapperView(model: flow) { state, _ in
            
            CreditCardMVPFlowView(
                state: state.navigation,
                dismiss: dismiss,
                completeView: makeCompleteView
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
            statusConfig: .creditCardMVP
        )
    }
}

// MARK: - Flow View

struct CreditCardMVPFlowView<CompleteView: View>: View {
    
    let state: State?
    let dismiss: () -> Void
    let completeView: (State.Complete) -> CompleteView
    
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
            Text(String(describing: decision))
                .padding()
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
            case .approved:
                return .decision(.approved)
                
            case .rejected:
                return .decision(.rejected)
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
        case .inReview: self = .inflight
        }
    }
}
