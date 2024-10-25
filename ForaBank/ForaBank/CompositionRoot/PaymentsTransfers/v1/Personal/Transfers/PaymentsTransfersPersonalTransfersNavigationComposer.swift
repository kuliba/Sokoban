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
        _ element: Domain.Element,
        notify: @escaping (Domain.FlowEvent) -> Void
    ) -> Domain.Navigation? {
        
        switch element {
        case let .buttonType(buttonType):
            return compose(for: buttonType, using: notify)
            
        case let .contactAbroad(source):
            // handleContactAbroad
            // PaymentsTransfersViewModel.swift:1359
            return .paymentsViewModel(nanoServices.makeSource(source, notify))
            
        case let .contacts(source):
            return .paymentsViewModel(nanoServices.makeSource(source, notify))
            
        case let .countries(source):
            // PaymentsTransfersViewModel.handleCountriesItemTapped(source:)
            // PaymentsTransfersViewModel.swift:1528
            return .paymentsViewModel(nanoServices.makeSource(source, notify))
            
        case let .latest(latest):
            return nanoServices.makeLatest(latest, notify).map { .payments($0) }
            
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
    ) -> Domain.Navigation? {
        
        switch buttonType {
        case .abroad:
            return .contacts(nanoServices.makeAbroad(notify))
            
        case .anotherCard:
            return .payments(nanoServices.makeAnotherCard(notify))
            
        case .betweenSelf:
            return nanoServices.makeMeToMe(notify).map { .meToMe($0) }
            
        case .byPhoneNumber:
            return .contacts(nanoServices.makeContacts(notify))
            
        case .requisites:
            return .payments(nanoServices.makeDetail(notify))
        }
    }
    
    func compose(
        for qr: Domain.Element.QR,
        using notify: @escaping (Domain.FlowEvent) -> Void
    ) -> Domain.Navigation? {
        
        switch qr {
        case .cancelled:
            return nil
            
        case .inflight:
            #warning("fixme")
            return nil
            
        case let .qrResult(qrResult):
            #warning("fixme")
            _ = qrResult
            return nil
            
        case .scan:
            // PaymentsTransfersViewModel.swift:1348
            return .scanQR(nanoServices.makeScanQR(notify))
        }
    }
}
