//
//  RootViewModelFactory+makePaymentsNode.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.11.2024.
//

extension RootViewModelFactory {
    
    func makePaymentsNode(
        payload: PaymentsViewModel.Payload,
        notifyClose: @escaping () -> Void
    ) -> Node<PaymentsViewModel> {
        
        let payments = PaymentsViewModel(
            payload: payload,
            model: model,
            closeAction: notifyClose
        )
        
        let scanQR = payments.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .sink { _ in notifyClose () }
        
        return .init(
            model: payments,
            cancellables: [scanQR]
        )
    }
}

extension PaymentsViewModel {
    
    enum Payload {
        
        case category(Payments.Category)
        case service(Payments.Service)
        case source(Payments.Operation.Source)
    }
    
    convenience init(
        payload: Payload,
        model: Model,
        closeAction: @escaping () -> Void
    ) {
        switch payload {
        case let .category(category):
            self.init(category: category, model: model, closeAction: closeAction)
            
        case let .service(service):
            self.init(model, service: service, closeAction: closeAction)
            
        case let .source(source):
            self.init(source: source, model: model, closeAction: closeAction)
        }
    }
}
