//
//  PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

final class PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.scheduler = scheduler
    }
}

extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    func compose(
        notify: @escaping Notify
    ) -> NanoServices {
        
        return .init(
            makeAbroad: { self.makeAbroad(notify: $0) },
            makeAnotherCard: { self.makeAnotherCard(notify: $0) },
            makeContacts: { self.makeContacts(notify: $0) },
            makeDetailPayment: { self.makeDetailPayment(notify: $0) },
            makeMeToMe: { self.makeMeToMe(notify: $0) }
        )
    }

    typealias Event = PaymentsTransfersPersonalTransfersDomain.FlowEvent
    typealias Notify = (Event) -> Void

    typealias NanoServices = PaymentsTransfersPersonalTransfersNavigationComposerNanoServices
}

private extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    func makeAbroad(
        notify: @escaping Notify
    ) -> Node<ContactsViewModel> {
        
        let abroad = model.makeContactsViewModel(forMode: .abroad)
        let cancellable = bind(abroad)
        
        return .init(model: abroad, cancellable: cancellable)
    }
    
    func makeAnotherCard(
        notify: @escaping Notify
    ) -> Node<ClosePaymentsViewModelWrapper>{
        
        model.action.send(ModelAction.ProductTemplate.List.Request())
        
        let anotherCard = ClosePaymentsViewModelWrapper(
            model: model,
            service: .toAnotherCard,
            scheduler: scheduler
        )
        let cancellable = bind(anotherCard)
        
        return .init(model: anotherCard, cancellable: cancellable)
    }
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1338
    private func bind(
        _ wrapper: ClosePaymentsViewModelWrapper
    ) -> AnyCancellable {
        
        wrapper.paymentsViewModel.action
            .sink { action in
                
                switch action {
                case _ as PaymentsViewModelAction.ScanQrCode:
#warning("FIXME using notify")
                    //    self.event(.dismiss(.destination))
                    //    self.delay(for: .milliseconds(800)) {
                    //        self.openScanner()
                    //    }
                    
                case let payload as PaymentsViewModelAction.ContactAbroad:
#warning("FIXME using notify")
                    _ = payload
                    //    handleContactAbroad(source: payload.source)
                    
                default: break
                }
            }
    }
    
    func makeContacts(
        notify: @escaping Notify
    ) -> Node<ContactsViewModel> {
        
        let contacts = model.makeContactsViewModel(
            forMode: .fastPayments(.contacts)
        )
        let cancellable = bind(contacts)
        
        return .init(model: contacts, cancellable: cancellable)
    }
    
    func makeDetailPayment(
        notify: @escaping Notify
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        let detailPayment = ClosePaymentsViewModelWrapper(
            model: model,
            service: .requisites,
            scheduler: scheduler
        )
        let cancellable = bind(detailPayment)
        
        return .init(model: detailPayment, cancellable: cancellable)
    }
    
    func makeMeToMe(
        notify: @escaping Notify
    ) -> Node<PaymentsMeToMeViewModel>? {
        
        guard let meToMe = PaymentsMeToMeViewModel(model, mode: .demandDeposit)
        else { return nil }
        
        let cancellable = bind(meToMe)
        
        return .init(model: meToMe, cancellable: cancellable)
    }
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1379
    private func bind(
        _ meToMe: PaymentsMeToMeViewModel
    ) -> AnyCancellable {
        
        meToMe.action
            .sink { [weak meToMe] action in
                
                switch action {
                case let payload as PaymentsMeToMeAction.Response.Success:
#warning("FIXME using notify")
                    _ = payload
                    //    handleSuccessResponseMeToMe(
                    //        meToMeViewModel: meToMe,
                    //        successViewModel: payload.viewModel
                    //    )
                    
                case _ as PaymentsMeToMeAction.Response.Failed:
#warning("FIXME using notify")
                    //    makeAlert("Перевод выполнен")
                    //    self.event(.dismiss(.modal))
                    
                case _ as PaymentsMeToMeAction.Close.BottomSheet:
#warning("FIXME using notify")
                    //    self.event(.dismiss(.modal))
                    
                case let payload as PaymentsMeToMeAction.InteractionEnabled:
#warning("FIXME using notify")
                    _ = payload
                    //    guard case let .bottomSheet(bottomSheet) = route.modal
                    //    else { return }
                    //
                    //    bottomSheet.isUserInteractionEnabled.value = payload.isUserInteractionEnabled
                    
                default:
                    break
                }
            }
    }
}

// MARK: - bindings

private extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1457
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

}
