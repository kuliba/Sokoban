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
    
    private let makeQRModel: MakeQRScannerModel
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        makeQRModel: @escaping MakeQRScannerModel,
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeQRModel = makeQRModel
        self.model = model
        self.scheduler = scheduler
    }
    
    typealias MakeQRScannerModel = () -> QRScannerModel
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
    
    typealias NotifyEvent = PaymentsTransfersPersonalTransfersDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    typealias NanoServices = PaymentsTransfersPersonalTransfersNavigationComposerNanoServices
}

private extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    func makeAbroad(
        notify: @escaping Notify
    ) -> Node<ContactsViewModel> {
        
        let abroad = model.makeContactsViewModel(forMode: .abroad)
        let cancellables = bind(abroad, using: notify)
        
        return .init(model: abroad, cancellables: cancellables)
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
        let cancellables = bind(contacts, using: notify)
        
        return .init(model: contacts, cancellables: cancellables)
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
    ) -> Node<PaymentsViewModel> {
        
        let paymentsViewModel = PaymentsViewModel(
            source: source,
            model: model
        ) {
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
        
        let cancellables = bind(meToMe, using: notify)
        
        return .init(model: meToMe, cancellables: cancellables)
    }
}

// MARK: - bindings

private extension PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer {
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1457
    private func bind(
        _ contacts: ContactsViewModel,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let share = contacts.action
            .handleEvents(receiveOutput: { _ in notify(.dismiss) })
            .delay(for: .milliseconds(300), scheduler: scheduler)
            .share()
        
        let paymentRequested = share
            .compactMap(\.paymentRequested)
            .sink { payload in
                
                switch payload.source {
                case let .latestPayment(latestPaymentID):
                    notify(.select(.latest(latestPaymentID)))
                    
                default:
                    notify(.select(.contacts(payload.source)))
                }
            }
        
        let countriesItemTap = share
            .compactMap(\.countriesItemTap)
            .sink { notify(.select(.countries($0.source))) }
        
        return [paymentRequested, countriesItemTap]
    }
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1338
    private func bind(
        _ paymentsViewModel: PaymentsViewModel,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let share = paymentsViewModel.action.share()
        
        let scanQR = share
            .compactMap(\.scanQR)
            .sink { _ in notify(.select(.scanQR)) }
        
        let contactAbroad = share
            .compactMap(\.contactAbroad)
            .delay(for: .milliseconds(700), scheduler: scheduler)
            .sink { notify(.select(.contactAbroad($0.source))) }
        
        return [scanQR, contactAbroad]
    }
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1379
    private func bind(
        _ meToMe: PaymentsMeToMeViewModel,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let share = meToMe.action.share()
        
        let success = share
            .compactMap(\.meToMeResponseSuccess)
            .sink {
                //    handleSuccessResponseMeToMe(
                //        meToMeViewModel: meToMe,
                //        successViewModel: payload.viewModel
                //    )
                let cancellables = self.bind($0, using: notify)
                
                notify(.select(.successMeToMe(.init(
                    model: $0,
                    cancellables: cancellables
                ))))
            }
        
        let failure = share
            .compactMap(\.meToMeResponseFailed)
            .sink { _ in
                //    makeAlert("Перевод выполнен")
                //    self.event(.dismiss(.modal))
                notify(.select(.alert("Перевод выполнен")))
            }
        
        let closeBottomSheet = share
            .compactMap(\.meToMeCloseBottomSheet)
            .sink { _ in
                //    self.event(.dismiss(.modal))
                notify(.dismiss)
            }
        
        let enable = share
            .compactMap(\.meToMeInteractionEnabled)
            .sink {
                //    guard case let .bottomSheet(bottomSheet) = route.modal
                //    else { return }
                //
                //    bottomSheet.isUserInteractionEnabled.value = payload.isUserInteractionEnabled
#warning("unimplemented")
                _ = $0
            }
        
        return [success, failure, closeBottomSheet, enable]
    }
    
    private func bind(
        _ success: PaymentsSuccessViewModel,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let share = success.action.share()
        
        let close = share
            .compactMap(\.successButtonClose)
            .sink { _ in notify(.dismiss) }
        
        let `repeat` = share
            .compactMap(\.successButtonRepeat)
            .sink { _ in notify(.dismiss) }
        
        return [close, `repeat`]
    }
}

// MARK: - Helpers

private extension Action {
    
    var contactAbroad: PaymentsViewModelAction.ContactAbroad? {
        
        self as? PaymentsViewModelAction.ContactAbroad
    }
    
    var countriesItemTap: ContactsSectionViewModelAction.Countries.ItemDidTapped? {
        
        self as? ContactsSectionViewModelAction.Countries.ItemDidTapped
    }
    
    var meToMeResponseSuccess: PaymentsSuccessViewModel? {
        
        guard let success = self as? PaymentsMeToMeAction.Response.Success
        else { return nil }
        
        return success.viewModel
    }
    
    var meToMeResponseFailed: PaymentsMeToMeAction.Response.Failed? {
        
        self as? PaymentsMeToMeAction.Response.Failed
    }
    
    var meToMeCloseBottomSheet: PaymentsMeToMeAction.Close.BottomSheet? {
        
        self as? PaymentsMeToMeAction.Close.BottomSheet
    }
    
    var meToMeInteractionEnabled: Bool? {
        
        guard let enabled = self as? PaymentsMeToMeAction.InteractionEnabled
        else { return nil }
        
        return enabled.isUserInteractionEnabled
    }
    
    var paymentRequested: ContactsViewModelAction.PaymentRequested? {
        
        self as? ContactsViewModelAction.PaymentRequested
    }
    
    var scanQR: PaymentsViewModelAction.ScanQrCode? {
        
        self as? PaymentsViewModelAction.ScanQrCode
    }
    
    var successButtonClose: PaymentsSuccessAction.Button.Close? {
        
        self as? PaymentsSuccessAction.Button.Close
    }
    
    var successButtonRepeat: PaymentsSuccessAction.Button.Repeat? {
        
        self as? PaymentsSuccessAction.Button.Repeat
    }
}
