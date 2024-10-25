//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServices.swift
//  ForaBank
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
    
    typealias Event = PaymentsTransfersPersonalTransfersDomain.FlowEvent
    typealias Notify = (Event) -> Void
    
    typealias MakeAbroad = (@escaping Notify) -> Node<ContactsViewModel>
    typealias MakeAnotherCard = (@escaping Notify) -> Node<ClosePaymentsViewModelWrapper>
    typealias MakeContacts = (@escaping Notify) -> Node<ContactsViewModel>
    typealias MakeDetail = (@escaping Notify) -> Node<ClosePaymentsViewModelWrapper>
    typealias MakeLatest = (LatestPaymentData.ID, @escaping Notify) -> Node<ClosePaymentsViewModelWrapper>?
    typealias MakeMeToMe = (@escaping Notify) -> Node<PaymentsMeToMeViewModel>?
    typealias MakeSource = (Payments.Operation.Source, @escaping Notify) -> Node<PaymentsViewModel>
}
