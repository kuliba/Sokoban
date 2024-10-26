//
//  PaymentsTransfersPersonalTransfersNavigationComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

final class PaymentsTransfersPersonalTransfersNavigationComposer {
    
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = PaymentsTransfersPersonalTransfersNavigationComposerNanoServices
}

extension PaymentsTransfersPersonalTransfersNavigationComposer {
    
    func compose(
        _ select: Domain.Select,
        notify: @escaping (Domain.FlowEvent) -> Void
    ) -> Domain.NavigationResult {
        
        switch select {
        case let .buttonType(buttonType):
            return compose(for: buttonType, using: notify)
            
        case let .contactAbroad(source):
            // handleContactAbroad
            // PaymentsTransfersViewModel.swift:1359
            return .success(.paymentsViewModel(nanoServices.makeSource(source, notify)))
            
        case let .contacts(source):
            return .success(.paymentsViewModel(nanoServices.makeSource(source, notify)))
            
        case let .countries(source):
            // PaymentsTransfersViewModel.handleCountriesItemTapped(source:)
            // PaymentsTransfersViewModel.swift:1528
            return .success(.paymentsViewModel(nanoServices.makeSource(source, notify)))
            
        case let .latest(latest):
            return .makeLatest(nanoServices.makeLatest(latest, notify))
            
        case let .qr(qr):
            return compose(for: qr, using: notify)
        }
    }
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
}

private extension PaymentsTransfersPersonalTransfersNavigationComposer {
    
    func compose(
        for buttonType: Domain.ButtonType,
        using notify: @escaping (Domain.FlowEvent) -> Void
    ) -> Domain.NavigationResult {
        
        switch buttonType {
        case .abroad:
            return .success(.contacts(nanoServices.makeAbroad(notify)))
            
        case .anotherCard:
            return .success(.payments(nanoServices.makeAnotherCard(notify)))
            
        case .betweenSelf:
            return .makeMeToMe(nanoServices.makeMeToMe(notify))
            
        case .byPhoneNumber:
            return .success(.contacts(nanoServices.makeContacts(notify)))
            
        case .requisites:
            return .success(.payments(nanoServices.makeDetail(notify)))
        }
    }
    
    // bind QRModel
    // PaymentsTransfersViewModel.swift:1567
    func compose(
        for qr: Domain.Select.QR,
        using notify: @escaping (Domain.FlowEvent) -> Void
    ) -> Domain.NavigationResult {
        
        switch qr {
        case let .result(result):
#warning("fixme")
            _ = result
            return { fatalError() }()
            
        case .scan:
            // PaymentsTransfersViewModel.swift:1348
            return .success(.scanQR(nanoServices.makeScanQR(notify)))
        }
    }
}

private extension PaymentsTransfersPersonalTransfersDomain.NavigationResult {
    
    static func makeLatest(
        _ node: Node<ClosePaymentsViewModelWrapper>?
    ) -> Self {
        
        node.map { .success(.payments($0)) } ?? .failure(.makeLatestFailure)
    }
    
    static func makeMeToMe(
        _ node: Node<PaymentsMeToMeViewModel>?
    ) -> Self {
        
        node.map { .success(.meToMe($0)) } ?? .failure(.makeMeToMeFailure)
    }
}
