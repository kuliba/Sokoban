//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.10.2024.
//

struct PaymentsTransfersPersonalTransfersNavigationComposerNanoServices {
    
    let makeAbroad: MakeAbroad
    let makeAnotherCard: MakeAnotherCard
    let makeContacts: MakeContacts
    let makeDetail: MakeDetail
    let makeLatest: MakeLatest
    let makeMeToMe: MakeMeToMe
    let makeSource: MakeSource
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServices{
    
    typealias NotifyEvent = PaymentsTransfersPersonalTransfersDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    typealias MakeAbroad = MakeContacts
    typealias MakeAnotherCard = MakePayments
    typealias MakeContacts = (@escaping Notify) -> Node<ContactsViewModel>
    typealias MakeDetail = MakePayments
    typealias MakeLatest = (LatestPaymentData.ID, @escaping Notify) -> Node<PaymentsViewModel>?
    typealias MakeMeToMe = (@escaping Notify) -> Node<PaymentsMeToMeViewModel>?
    typealias MakeSource = (Payments.Operation.Source, @escaping Notify) -> Node<PaymentsViewModel>

    typealias MakePayments = (@escaping Notify) -> Node<PaymentsViewModel>
}
