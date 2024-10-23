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
    
    typealias Event = PaymentsTransfersPersonalTransfersDomain.FlowEvent
    typealias Notify = (Event) -> Void
    
    typealias MakeAnotherCard = (@escaping Notify) -> Node<ClosePaymentsViewModelWrapper>
    typealias MakeContactsViewModel = (@escaping Notify) -> Node<ContactsViewModel>
    typealias MakeDetailPayment = (@escaping Notify) -> Node<ClosePaymentsViewModelWrapper>
    typealias MakeMeToMe = (@escaping Notify) -> Node<PaymentsMeToMeViewModel>?
}
