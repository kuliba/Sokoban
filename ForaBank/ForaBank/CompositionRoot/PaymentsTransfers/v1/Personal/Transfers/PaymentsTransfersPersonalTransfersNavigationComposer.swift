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
            return compose(for: buttonType, notify: notify)
        }
    }
     
    private func compose(
        for buttonType: Domain.ButtonType,
        notify: @escaping (Domain.FlowEvent) -> Void
    ) -> Domain.Navigation? {
        
        switch buttonType {
        case .abroad:
            return .contacts(nanoServices.makeAbroad())
            
        case .anotherCard:
            return .payments(nanoServices.makeAnotherCard())
            
        case .betweenSelf:
            return nanoServices.makeMeToMe().map { .meToMe($0) }
            
        case .byPhoneNumber:
            return .contacts(nanoServices.makeContacts())
            
        case .requisites:
            return .payments(nanoServices.makeDetailPayment())
        }
    }
    
    typealias Domain = PaymentsTransfersPersonalTransfersDomain
}
