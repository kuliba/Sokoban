//
//  SelectedCategoryNavigationMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

final class SelectedCategoryNavigationMicroServicesComposer {
    
    private let model: Model
    private let nanoServices: NanoServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        nanoServices: NanoServices,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.nanoServices = nanoServices
        self.scheduler = scheduler
    }
    
    typealias NanoServices = CategoryPickerSectionMicroServicesComposerNanoServices
}

extension SelectedCategoryNavigationMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(getNavigation: getNavigation)
    }
    
    typealias Select = CategoryPickerSection.Select
    typealias Navigation = SelectedCategoryNavigation
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias MicroServices = FlowDomain.MicroServices
}

private extension SelectedCategoryNavigationMicroServicesComposer {
    
    typealias Notify = (FlowDomain.Event) -> Void
    
    func getNavigation(
        payload: Select,
        notify: @escaping Notify,
        completion: @escaping (SelectedCategoryNavigation) -> Void
    ) {
        switch payload {
        case let .category(category):
            getNavigation(category: category, notify, completion)
            
        case let .qrSelect(qrSelect):
            getNavigation(qrSelect: qrSelect, notify, completion)
        }
    }
    
    // MARK: - PickerSelect
    
    func getNavigation(
        category: ServiceCategory,
        _ notify: @escaping Notify,
        _ completion: @escaping (SelectedCategoryNavigation) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            completion(.paymentFlow(.mobile(nanoServices.makeMobile())))
            
        case .qr:
            let qr = nanoServices.makeQR()
            let cancellable = qr.$state
                .compactMap { $0 }
                .flatMap {
                    
                    self.notifyPublisher(
                        result: $0,
                        notify: { notify(.select(.qrSelect($0))) }
                    )
                }
                .sink(receiveValue: notify)
            
            completion(.paymentFlow(.qr(.init(
                model: qr,
                cancellable: cancellable
            ))))
            
        case .standard:
            nanoServices.makeStandard(category) {
                
                completion(.paymentFlow(.standard($0)))
            }
            
        case .taxAndStateServices:
            completion(.paymentFlow(.taxAndStateServices(nanoServices.makeTax())))
            
        case .transport:
            guard let transport = nanoServices.makeTransport()
            else { return completion(.failure(.transport)) }
            
            completion(.paymentFlow(.transport(transport)))
        }
    }
    
    private func notifyPublisher(
        result: QRModelWrapperState<QRModelResult>,
        notify: @escaping (QRNavigationComposer.NotifyEvent) -> Void
    ) -> AnyPublisher<FlowDomain.Event, Never> {
        
        switch result {            
        case .cancelled:
            return Just(.dismiss).eraseToAnyPublisher()
            
        case .inflight:
            return Empty<FlowDomain.Event, Never>().eraseToAnyPublisher()
            
        case let .qrResult(qrResult):
            return AnyPublisher { completion in
                
                self.nanoServices.makeQRNavigation(qrResult, notify) {
                    
                    completion(.receive(.qrNavigation($0)))
                }
            }.eraseToAnyPublisher()
        }
    }
    
    // MARK: - QRSelect
    
    func getNavigation(
        qrSelect payload: QRNavigationComposer.NotifyEvent,
        _ notify: @escaping (FlowDomain.Event) -> Void,
        _ completion: @escaping (SelectedCategoryNavigation) -> Void
    ) {
        switch payload {
        case let .contactAbroad(source):
            completion(.qrNavigation(.payments(.init(
                model: .init(
                    model: model,
                    source: source,
                    scheduler: scheduler
                ),
                cancellables: []
            ))))
            
        case let .detailPayment(qrCode):
            switch qrCode {
            case .none:
                let wrapper = ClosePaymentsViewModelWrapper(
                    model: model,
                    service: .requisites,
                    scheduler: scheduler
                )
                completion(.qrNavigation(.payments(.init(
                    model: wrapper,
                    cancellable: bind(wrapper, notify: notify)
                ))))
                
            case let .some(qrCode):
                let wrapper = ClosePaymentsViewModelWrapper(
                    model: model,
                    source: .requisites(qrCode: qrCode),
                    scheduler: scheduler
                )
                completion(.qrNavigation(.payments(.init(
                    model: wrapper,
                    cancellable: bind(wrapper, notify: notify)
                ))))
            }
            
        case .dismiss:
            #warning("completion is not called")
            notify(.dismiss)
            
        case let .isLoading(isLoading):
            #warning("completion is not called")
            
        case let .outside(outside):
            #warning("completion is not called")
            
        case let .sberPay(state):
            #warning("completion is not called")
            
        case .scanQR:
            #warning("completion is not called")
            notify(.select(.qrSelect(.scanQR)))
        }
    }
    
    private func bind(
        _ wrapper: ClosePaymentsViewModelWrapper,
        notify: @escaping (FlowDomain.Event) -> Void
    ) -> AnyCancellable {
        
        wrapper.$isClosed
            .combineLatest(wrapper.$isClosed.dropFirst())
            .filter { $0.0 == false && $0.1 == true }
            .sink { _ in notify(.dismiss) }
    }
}

private extension SelectedCategoryFailure {
    
    static let transport: Self = .init(
        id: .init(),
        message: "Ошибка создания транспортных платежей"
    )
}
