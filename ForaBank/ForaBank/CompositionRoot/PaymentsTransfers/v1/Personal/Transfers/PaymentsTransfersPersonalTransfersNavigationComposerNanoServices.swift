//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServices.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

struct PaymentsTransfersPersonalTransfersNavigationComposerNanoServices {
    
    let makeAbroad: MakeContactsViewModel
    let makeAnotherCard: MakeAnotherCard
    let makeContacts: MakeContactsViewModel
    let makeDetailPayment: MakeDetailPayment
    let makeMeToMe: MakeMeToMe
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServices{
    
    typealias MakeAnotherCard = () -> Node<ClosePaymentsViewModelWrapper>
    typealias MakeContactsViewModel = () -> Node<ContactsViewModel>
    typealias MakeDetailPayment = () -> Node<ClosePaymentsViewModelWrapper>
    typealias MakeMeToMe = () -> Node<PaymentsMeToMeViewModel>?
}
