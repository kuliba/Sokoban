//
//  QRNavigationComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.10.2024.
//

import Combine
import Foundation
import SberQR

final class QRNavigationComposer {
    
    private let microServices: MicroServices
    
    init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    typealias MicroServices = QRNavigationComposerMicroServices
}

extension QRNavigationComposer {
    
    func getNavigation(
        payload: Payload,
        notify: @escaping Notify,
        completion: @escaping QRNavigationCompletion
    ) {
        switch payload {
        case let .qrResult(result):
            handle(result: result, with: notify, and: completion)
            
        case let .sberPay(url, state):
            microServices.makeSberPaymentComplete((url, state)) {
                completion(.paymentComplete($0))
            }
        }
    }
    
    enum Payload: Equatable {
        
        case qrResult(QRModelResult)
        case sberPay(URL, SberQRConfirmPaymentState)
    }
    
    enum NotifyEvent {
        
        case contactAbroad(Payments.Operation.Source)
        case detailPayment(QRCode?)
        case dismiss
        case isLoading(Bool)
        case outside(Outside)
        case qrNavigation(QRNavigation)
        case sberPay(SberQRConfirmPaymentState)
        case scanQR
        
        enum Outside: Equatable {
            
            case chat, main, payments
        }
    }
    
    typealias Notify = (NotifyEvent) -> Void
    
    typealias QRNavigationCompletion = (QRNavigation) -> Void
}

private extension QRNavigationComposer {
    
    func handle(
        result: QRModelResult,
        with notify: @escaping Notify,
        and completion: @escaping QRNavigationCompletion
    ) {
        switch result {
        case let .c2bSubscribeURL(url):
            handle(.source(.c2bSubscribe(url)), with: notify, and: completion)
            
        case let .c2bURL(url):
            handle(.source(.c2b(url)), with: notify, and: completion)
            
        case let .failure(qrCode):
            let payload = MicroServices.MakeQRFailureWithQRPayload(
                qrCode: qrCode,
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment($0)) }
            )
            microServices.makeQRFailureWithQR(payload) { completion(.failure($0)) }
            
        case let .mapped(mapped):
            handle(mapped: mapped, with: notify, and: completion)
            
        case let .sberQR(url):
            microServices.makeSberQR((url, { notify(.sberPay($0)) })) {
                
                switch $0 {
                case let .failure(error):
                    completion(.sberQR(.failure(error)))
                    
                case let .success(sberQR):
                    completion(.sberQR(.success(sberQR)))
                }
            }
            
        case .url(_):
            makeQRFailure(with: notify) { completion(.failure($0)) }
            
        case .unknown:
            makeQRFailure(with: notify) { completion(.failure($0)) }
        }
    }
    
    func handle(
        mapped: QRModelResult.Mapped,
        with notify: @escaping Notify,
        and completion: @escaping QRNavigationCompletion
    ) {
        switch mapped {
        case .missingINN:
            makeQRFailure(with: notify) { completion(.failure($0)) }
            
        case let .mixed(mixed):
            let payload = MicroServices.MakeProviderPickerPayload(
                mixed: mixed.operators,
                qrCode: mixed.qrCode,
                qrMapping: mixed.qrMapping
            )
            microServices.makeProviderPicker(payload) { [weak self] in
                
                guard let self else { return }
                
                completion(.providerPicker(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .multiple(multiple, qrCode, qrMapping):
            let payload = MicroServices.MakeOperatorSearchPayload(
                multiple: multiple,
                qrCode: qrCode,
                qrMapping: qrMapping,
                chat: { notify(.outside(.chat)) },
                detailPayment: { notify(.detailPayment(nil)) },
                dismiss: { notify(.dismiss) }
            )
            microServices.makeOperatorSearch(payload) { completion(.operatorSearch($0)) }
            
        case let .none(qrCode):
            handle(.qrCode(qrCode), with: notify, and: completion)
            
        case let .provider(payload):
            microServices.makeServicePicker(payload) { [weak self] in
                
                guard let self else { return }
                
                completion(.servicePicker(.init(
                    model: $0,
                    cancellables: self.bind($0, with: notify)
                )))
            }
            
        case let .single(_, qrCode, qrMapping):
            microServices.makeInternetTV((qrCode, qrMapping)) { completion(.internetTV($0)) }
            
        case let .source(source):
            handle(.operationSource(source), with: notify, and: completion)
        }
    }
    
    func handle(
        _ payload: MicroServices.MakePaymentsPayload,
        with notify: @escaping Notify,
        and completion: @escaping (QRNavigation) -> Void
    ) {
        microServices.makePayments(payload) { [weak self] in
            
            guard let self else { return }
            
            completion(.payments(.init(
                model: $0,
                cancellables: self.bind($0, with: notify)
            )))
        }
    }
    
    func makeQRFailure(
        with notify: @escaping Notify,
        completion: @escaping (QRFailedViewModel) -> Void
    ) {
        let payload = MicroServices.MakeQRFailurePayload(
            chat: { notify(.outside(.chat)) },
            detailPayment: { notify(.detailPayment(nil)) }
        )
        microServices.makeQRFailure(payload) { completion($0) }
    }
    
    func bind(
        _ wrapper: ClosePaymentsViewModelWrapper,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = wrapper.$isClosed
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = wrapper.paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .sink { _ in notify(.scanQR) }
        
        let contactAbroad = wrapper.paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ContactAbroad }
            .map(\.source)
            .sink { notify(.contactAbroad($0)) }
        
        return [close, scanQR, contactAbroad]
    }
    
    func bind(
        _ picker: QRNavigation.ProviderPicker,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let isLoading = picker.$state.map(\.isLoading)
        let isLoadingFlip = isLoading
            .combineLatest(isLoading.dropFirst())
            .filter { $0 != $1 }
            .map(\.0)
            .sink { notify(.isLoading($0)) }
        
        let outside = picker.$state
            .compactMap(\.notifyEvent)
            .sink { notify($0) }
        
        return [isLoadingFlip, outside]
    }
    
    func bind(
        _ flow: AnywayServicePickerFlowModel,
        with notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let isLoading = flow.$state.map(\.isLoading)
        let isLoadingFlip = isLoading
            .combineLatest(isLoading.dropFirst())
            .filter { $0 != $1 }
            .map(\.0)
            .sink { notify(.isLoading($0)) }
        
        let outside = flow.$state
            .compactMap(\.notifyEvent)
            .sink { notify($0) }
        
        return [isLoadingFlip, outside]
    }
}

private extension SegmentedPaymentProviderPickerFlowState {
    
    var notifyEvent: QRNavigationComposer.NotifyEvent? {
        
        switch outside {
        case .none:       return .none
        case .addCompany: return .outside(.chat)
        case .main:       return .outside(.main)
        case .payments:   return .outside(.payments)
        case .scanQR:     return .scanQR
        }
    }
}

private extension AnywayServicePickerFlowState {
    
    var notifyEvent: QRNavigationComposer.NotifyEvent? {
        
        switch outside {
        case .none:       return .none
        case .addCompany: return .outside(.chat)
        case .main:       return .outside(.main)
        case .payments:   return .outside(.payments)
        case .scanQR:     return .scanQR
        }
    }
}
