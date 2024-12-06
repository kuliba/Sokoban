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
    let makeScanQR: MakeScanQR
    let makeSource: MakeSource
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServices{
    
    typealias NotifyEvent = PaymentsTransfersPersonalTransfersDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    typealias MakeAbroad = MakeContacts
    typealias MakeAnotherCard = MakePaymentsWrapper
    typealias MakeContacts = (@escaping Notify) -> Node<ContactsViewModel>
    typealias MakeDetail = MakePaymentsWrapper
    typealias MakeLatest = (LatestPaymentData.ID, @escaping Notify) -> Node<ClosePaymentsViewModelWrapper>?
    typealias MakeMeToMe = (@escaping Notify) -> Node<PaymentsMeToMeViewModel>?
    typealias MakeScanQR = (@escaping Notify) -> Node<QRScannerModel>
    typealias MakeSource = (Payments.Operation.Source, @escaping Notify) -> Node<PaymentsViewModel>

    typealias MakePaymentsWrapper = (@escaping Notify) -> Node<ClosePaymentsViewModelWrapper>
}
