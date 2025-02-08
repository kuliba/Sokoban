//
//  RootViewModelFactory+makeMeToMeNode.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.01.2025.
//

import Combine

// TODO: remove duplication - see PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer
// TODO: extract as separate binder(?)
extension RootViewModelFactory {
    
    typealias MeToMeNotifyEvent = FlowEvent<MeToMeSelect, Never>
    typealias MeToMeNotify = (MeToMeNotifyEvent) -> Void
    
    enum MeToMeSelect {
        
        case alert(String)
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
    
    @inlinable
    func makeMeToMeNode(
        notify: @escaping MeToMeNotify
    ) -> Node<PaymentsMeToMeViewModel>? {
        
        guard let meToMe = PaymentsMeToMeViewModel(model, mode: .demandDeposit)
        else { return nil }
        
        let cancellables = bind(meToMe, using: notify)
        
        return .init(model: meToMe, cancellables: cancellables)
    }
    
    // PaymentsTransfersViewModel.bind(_:)
    // PaymentsTransfersViewModel.swift:1379
    @inlinable
    func bind(
        _ meToMe: PaymentsMeToMeViewModel,
        using notify: @escaping MeToMeNotify
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
    
    @inlinable
    func bind(
        _ success: PaymentsSuccessViewModel,
        using notify: @escaping MeToMeNotify
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
