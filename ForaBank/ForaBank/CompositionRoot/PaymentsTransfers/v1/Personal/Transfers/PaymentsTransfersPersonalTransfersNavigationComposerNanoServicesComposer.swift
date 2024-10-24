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
    
    func compose() -> NanoServices {
        
        return .init(
            makeAbroad: { self.makeAbroad(notify: $0) },
            makeAnotherCard: { self.makeAnotherCard(notify: $0) },
            makeContacts: { self.makeContacts(notify: $0) },
            makeDetail: { self.makeDetail(notify: $0) },
            makeLatest: { self.makeLatest(latest: $0, notify: $1) },
            makeMeToMe: { self.makeMeToMe(notify: $0) },
            makeSource: { self.makeSource(source: $0, notify: $1) }
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
        let cancellable = bind(abroad, notify: notify)
        
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
        let cancellables = bind(anotherCard.paymentsViewModel, using: notify)
        
        return .init(model: anotherCard, cancellables: cancellables)
    }
    
    func makeContacts(
        notify: @escaping Notify
    ) -> Node<ContactsViewModel> {
        
        let contacts = model.makeContactsViewModel(
            forMode: .fastPayments(.contacts)
        )
        let cancellable = bind(contacts, notify: notify)
        
        return .init(model: contacts, cancellable: cancellable)
    }
    
    func makeDetail(
        notify: @escaping Notify
    ) -> Node<ClosePaymentsViewModelWrapper> {
        
        let detailPayment = ClosePaymentsViewModelWrapper(
            model: model,
            service: .requisites,
            scheduler: scheduler
        )
        let cancellables = bind(detailPayment.paymentsViewModel, using: notify)
        
        return .init(model: detailPayment, cancellables: cancellables)
    }
    
    func makeLatest(
        latest: LatestPaymentData.ID,
        notify: @escaping Notify
    ) -> Node<ClosePaymentsViewModelWrapper>? {
        
        guard let latest = model.latestPayments.value.first(where: { $0.id == latest }),
              // pasted from PaymentsTransfersViewModel.swift:341
              // but might need updated approach with payment flow?
                [LatestPaymentData.Kind.internet, .service, .mobile, .outside, .phone, .transport, .taxAndStateService].contains(latest.type)
        else { return nil }
        
        let wrapper = ClosePaymentsViewModelWrapper(
            model: model,
            source: .latestPayment(latest.id),
            scheduler: scheduler
        )
        
        let cancellables = bind(wrapper.paymentsViewModel, using: notify)
        
        return .init(model: wrapper, cancellables: cancellables)
    }
    
    func makeSource(
        source: Payments.Operation.Source,
        notify: @escaping Notify
    ) -> Node<PaymentsViewModel>? {
        
        let paymentsViewModel = PaymentsViewModel(
            source: source,
            model: model
        ) { [weak self] in
            
            guard let self else { return }
            
            switch source {
            case .direct:
                notify(.select(.buttonType(.abroad)))
                
            case .sfp:
                notify(.select(.buttonType(.byPhoneNumber)))
                
            default: break
            }
        }
        
        let cancellables = bind(paymentsViewModel, using: notify)
        
        return .init(model: paymentsViewModel, cancellables: cancellables)
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
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1338
    private func bind(
        _ paymentsViewModel: PaymentsViewModel,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let scanQR = paymentsViewModel.action
            .compactMap(\.scanQR)
            .handleEvents(receiveOutput: { _ in notify(.dismiss) })
            .delay(for: .milliseconds(800), scheduler: scheduler)
            .sink { _ in notify(.select(.scanQR)) }
        
        let contactAbroad = paymentsViewModel.action
            .sink { action in
                
                switch action {
                case let payload as PaymentsViewModelAction.ContactAbroad:
#warning("FIXME using notify")
                    _ = payload
                    //    handleContactAbroad(source: payload.source)
                    
                default: break
                }
            }
        
        return [scanQR, contactAbroad]
    }
}

// MARK: - bindings

private extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1457
    private func bind(
        _ contacts: ContactsViewModel,
        notify: @escaping Notify
    ) -> AnyCancellable {
        
        contacts.action
            .handleEvents(receiveOutput: { _ in notify(.dismiss) })
            .delay(for: .milliseconds(300), scheduler: scheduler)
            .sink { action in
                
                switch action {
                case let payload as ContactsViewModelAction.PaymentRequested:
                    switch payload.source {
                    case let .latestPayment(latestPaymentID):
                        notify(.select(.latest(latestPaymentID)))
                        
                    default:
                        notify(.select(.contacts(payload.source)))
                    }
                    
                case let payload as ContactsSectionViewModelAction.Countries.ItemDidTapped:
                    notify(.select(.countries(payload.source)))
                    
                default:
                    break
                }
            }
    }
}

private extension Action {
    
    var scanQR: PaymentsViewModelAction.ScanQrCode? {
        
        self as? PaymentsViewModelAction.ScanQrCode
    }
}
