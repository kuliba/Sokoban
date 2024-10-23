//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import Combine
import Foundation

final class PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    private let model: Model
    
    init(model: Model) {
        
        self.model = model
    }
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        return .init(
            makeAbroad: makeAbroad,
            makeAnotherCard: makeAnotherCard,
            makeContacts: makeContacts,
            makeDetailPayment: makeDetailPayment,
            makeMeToMe: makeMeToMe
        )
    }
    
    typealias NanoServices = PaymentsTransfersPersonalTransfersNavigationComposerNanoServices
}

private extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    func makeAbroad() -> Node<ContactsViewModel> {
        
        fatalError()
    }
    
    func makeAnotherCard() -> Node<PaymentsViewModel>{
        
        fatalError()
    }
    
    func makeContacts() -> Node<ContactsViewModel> {
        
        let contacts = model.makeContactsViewModel(
            forMode: .fastPayments(.contacts)
        )
        let cancellable = bind(contacts)
        
        return .init(model: contacts, cancellable: cancellable)
    }
    
    private func bind(
        _ contacts: ContactsViewModel
    ) -> AnyCancellable {
        
        contacts.action
            .sink { action in
                
                switch action {
                case let payload as ContactsViewModelAction.PaymentRequested:
                    #warning("FIXME using notify")
                    _ = payload
                    // requestContactsPayment(source: payload.source)
                    
                case let payload as ContactsSectionViewModelAction.Countries.ItemDidTapped:
                    #warning("FIXME using notify")
                    _ = payload
                    // handleCountriesItemTapped(source: payload.source)
                    
                default:
                    break
                }
            }
    }
    
    func makeDetailPayment() -> Node<PaymentsViewModel> {
        
        fatalError()
    }
    
    func makeMeToMe() -> PaymentsMeToMeViewModel? {
        
        fatalError()
    }
}
