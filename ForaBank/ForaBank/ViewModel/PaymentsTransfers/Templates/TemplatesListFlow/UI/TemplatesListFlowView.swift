//
//  TemplatesListFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Combine
import SwiftUI

typealias MakeTemplatesListView = (TemplatesListViewModel) -> TemplatesListView

struct TemplatesListFlowViewFactory {
    
    let makePaymentsView: MakePaymentsView
    let makeTemplatesListView: MakeTemplatesListView
}

struct TemplatesListFlowView<AnywayFlowView: View>: View {
    
    @ObservedObject var model: Model
    
    let makeAnywayFlowView: (AnywayFlowModel) -> AnywayFlowView
    let makeIconView: (String?) -> IconDomain.IconView
    let viewFactory: TemplatesListFlowViewFactory
    
    var body: some View {
        
        viewFactory.makeTemplatesListView(model.state.content)
            .alert(
                item: model.state.alert,
                content: alertContent
            )
            .navigationDestination(
                destination: model.state.destination,
                dismiss: { model.event(.dismiss(.destination)) },
                content: destinationContent
            )
    }
}

extension TemplatesListFlowView {
    
    typealias Model = TemplatesListFlowModel<TemplatesListViewModel, AnywayFlowModel>
}

extension TemplatesListFlowState {
    
    var alert: Status.ServiceFailure? {
        
        guard case let .alert(alert) = status
        else { return nil }
        
        return alert
    }
    
    var destination: Status.Destination? {
        
        guard case let .destination(destination) = status
        else { return nil }
        
        return destination
    }
}

extension TemplatesListFlowState.Status.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment: return .payment
        }
    }
    
    enum ID: Hashable {
        
        case payment
    }
}

extension TemplatesListViewModel: ProductIDEmitter {
    
    var productIDPublisher: AnyPublisher<ProductID, Never> {
        
        action
            .compactMap { $0 as? TemplatesListViewModelAction.OpenProductProfile }
            .map(\.productId)
            .eraseToAnyPublisher()
    }
}

extension TemplatesListViewModel: TemplateEmitter {
    
    var templatePublisher: AnyPublisher<PaymentTemplateData, Never> {
        
        action
            .compactMap { $0 as? TemplatesListViewModelAction.OpenDefaultTemplate }
            .map(\.template)
            .eraseToAnyPublisher()
    }
}

private extension TemplatesListFlowView {
    
    func alertContent(
        failure: ServiceFailureAlert.ServiceFailure
    ) -> Alert {
        
        return failure.alert(
            connectivityErrorMessage: "Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.",
            event: .payments,
            action: { model.event(.flow(.init(status: .tab($0)))) }
        )
    }
    
    @ViewBuilder
    func destinationContent(
        destination: Model.State.Status.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(payment):
            switch payment {
            case let .legacy(paymentsViewModel):
                viewFactory.makePaymentsView(paymentsViewModel)
                
            case let .v1(node):
                let payload = node.model.state.content.state.transaction.context.outline.payload
                
                makeAnywayFlowView(node.model)
                    .navigationBarWithAsyncIcon(
                        title: payload.title,
                        subtitle: payload.subtitle,
                        dismiss: { model.event(.dismiss(.destination)) },
                        icon: makeIconView(payload.icon),
                        style: .normal
                    )
            }
        }
    }
}
