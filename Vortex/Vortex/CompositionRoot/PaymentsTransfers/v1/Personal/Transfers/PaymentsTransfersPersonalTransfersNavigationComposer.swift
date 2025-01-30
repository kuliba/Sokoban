//
//  PaymentsTransfersPersonalTransfersNavigationComposer.swift
//  Vortex
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
    
    typealias Notify = (Domain.NotifyEvent) -> Void
    
    func compose(
        _ select: Domain.Select,
        notify: @escaping Notify
    ) -> Domain.Navigation {
        
        switch select {
        case let .alert(message):
            return .failure(.alert(message))
            
        case let .buttonType(buttonType):
            return compose(for: buttonType, using: notify)
            
        case let .contactAbroad(source):
            // handleContactAbroad
            // PaymentsTransfersViewModel.swift:1359
            return .success(.payments(nanoServices.makeSource(source, notify)))
            
        case let .contacts(source):
            return .success(.payments(nanoServices.makeSource(source, notify)))
            
        case let .countries(source):
            // PaymentsTransfersViewModel.handleCountriesItemTapped(source:)
            // PaymentsTransfersViewModel.swift:1528
            return .success(.payments(nanoServices.makeSource(source, notify)))
            
        case let .latest(latest):
            return .makeLatest(nanoServices.makeLatest(latest, notify))
            
        case .scanQR:
            return .success(.scanQR)
            
        case let .successMeToMe(node):
            return .success(.successMeToMe(node))
        }
    }
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
}

private extension PaymentsTransfersPersonalTransfersNavigationComposer {
    
    func compose(
        for buttonType: Domain.ButtonType,
        using notify: @escaping Notify
    ) -> Domain.Navigation {
        
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
}

private extension PaymentsTransfersPersonalTransfersDomain.Navigation {
    
    static func makeLatest(
        _ node: Node<PaymentsViewModel>?
    ) -> Self {
        
        node.map { .success(.payments($0)) } ?? .failure(.makeLatestFailure)
    }
    
    static func makeMeToMe(
        _ node: Node<PaymentsMeToMeViewModel>?
    ) -> Self {
        
        node.map { .success(.meToMe($0)) } ?? .failure(.makeMeToMeFailure)
    }
}
