//
//  RootViewModelFactory+makePaymentProviderPicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.01.2025.
//

import Combine
import PayHub
import RemoteServices

extension RootViewModelFactory {
    
    struct MakeSelectedCategorySuccessPayload {
        
        let category: ServiceCategory
        let latest: [Latest]
        let operators: [UtilityPaymentProvider]
    }
    
    @inlinable
    func makePaymentProviderPicker(
        payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Binder {
        
        let content = makeContent(with: payload)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getPaymentProviderPickerNavigation,
            witnesses: .init(emitting: emitting, dismissing: dismissing)
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: PaymentProviderPickerDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case .alert:       return .milliseconds(100)
        case .destination: return .milliseconds(100)
        case .outside:     return .milliseconds(100)
        }
    }
    
    @inlinable
    func getPaymentProviderPickerNavigation(
        select: PaymentProviderPickerDomain.Select,
        notify: @escaping PaymentProviderPickerDomain.FlowDomain.Notify,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        switch select {
        case .detailPayment:
            completion(.destination(.detailPayment(makePaymentsNode(
                payload: .service(.requisites),
                notify: { event in
                    
                    switch event {
                    case .close:  notify(.dismiss)
                    case .scanQR: notify(.select(.outside(.qr)))
                    }
                }
            ))))
            
        case let .latest(latest):
            initiateAnywayPayment(latest: latest, notify: notify, completion: completion)
            
        case let .outside(outside):
            completion(.outside(outside))
            
        case let .provider(provider):
            processProvider(provider: provider, notify: notify, completion: completion)
        }
    }
    
    @inlinable
    func initiateAnywayPayment(
        latest: Latest,
        notify: @escaping PaymentProviderPickerDomain.FlowDomain.Notify,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        initiateAnywayPayment(
            .latest(latest.origin.latest)
        ) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    completion(.alert(.paymentConnectivity))
                    
                case let .serverError(message):
                    completion(.alert(.server(message)))
                }
                
            case let .success(transaction):
                completion(makeNavigation(
                    transaction: transaction,
                    notify: notify
                ))
            }
        }
    }
    
    @inlinable
    func processProvider(
        provider: PaymentProviderPickerDomain.Provider,
        notify: @escaping PaymentProviderPickerDomain.FlowDomain.Notify,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        processSelection(
            select: (.operator(provider), provider.type)
        ) { [weak self] in
            
            guard let self else {
                
                return completion(.destination(.payment(.failure(.serviceFailure(.connectivityError)))))
            }
            
            switch $0 {
            case let .failure(failure):
                completion(failure.navigation)
                
            case let .success(success):
                switch success {
                case let .services(operatorServices):
                    
                    completion(.destination(.payment(.success(
                        .services(makeProviderServicePicker(
                            provider: operatorServices.operator.operator,
                            services: operatorServices.services
                        ))
                    ))))
                    
                case let .startPayment(transaction):
                    completion(makeNavigation(
                        transaction: transaction,
                        notify: notify
                    ))
                }
            }
        }
    }
    
    @inlinable
    func makeNavigation(
        transaction: AnywayTransactionState.Transaction,
        notify: @escaping PaymentProviderPickerDomain.FlowDomain.Notify
    ) -> (PaymentProviderPickerDomain.Navigation) {
        
        let flowModel = makeAnywayFlowModel(transaction: transaction)
        let cancellable = flowModel.$state
            .compactMap(\.outside)
            .sink { notify($0.notifyEvent) }
        
        return .destination(.payment(.success(
            .startPayment(.init(
                model: flowModel,
                cancellable: cancellable
            ))
        )))
    }
    
    // MARK: - Content
    
    @inlinable
    func makeContent(
        with payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Content {
        
        let providerList = makeProviderList(with: payload)
        let search = payload.category.hasSearch ? makeSearch() : nil
        
        return .init(
            title: payload.category.name,
            operationPicker: (),
            providerList: providerList,
            search: search,
            cancellables: bind(search, to: providerList)
        )
    }
    
    private func bind(
        _ search: PaymentProviderPickerDomain.Search?,
        to providerList: PaymentProviderPickerDomain.ProviderList
    ) -> Set<AnyCancellable> {
        
        let cancellable = search?.$state
            .map { $0.text ?? "" }
            .debounce(for: .milliseconds(300), scheduler: schedulers.main)
            .sink { [weak providerList] in providerList?.event(.search($0)) }
        
        return cancellable.map { [$0] } ?? []
    }
    
    private func makeProviderList(
        with payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.ProviderList {
        
        let reducer = PaymentProviderPickerDomain.ProviderListReducer(
            observeLast: settings.observeLast
        )
        let microServicesComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: settings.pageSize,
            nanoServices: .init(loadOperators: loadCachedOperators)
        )
        let effectHandler = PaymentProviderPickerDomain.ProviderListEffectHandler(
            microServices: microServicesComposer.compose(
                for: payload.category.type
            )
        )
        
        return .init(
            initialState: .init(
                lastPayments: payload.latest,
                operators: payload.operators,
                searchText: ""
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
    }
    
    private func makeSearch() -> RegularFieldViewModel {
        
        makeSearch(placeholderText: "Наименование или ИНН")
    }
    
    @inlinable
    func emitting(
        content: PaymentProviderPickerDomain.Content
    ) -> some Publisher<FlowEvent<PaymentProviderPickerDomain.Select, Never>, Never> {
        
        Empty()
    }
    
    @inlinable
    func dismissing(
        content: PaymentProviderPickerDomain.Content
    ) -> () -> Void {
        
        return {}
    }
}

// MARK: - Adapters

extension BackendFailure {
    
    static let paymentConnectivity: Self = .connectivity("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже.")
}

private extension RemoteServices.ResponseMapper.LatestPayment {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        switch self {
        case let .service(service):
            return service.latest
            
        case let .withPhone(withPhone):
            return withPhone.latest
        }
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, type: type.rawValue, additionalItems: additionalItems?.map(\.additional) ?? [])
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service.AdditionalItem {
    
    var additional: RemoteServices.ResponseMapper.LatestServicePayment.AdditionalItem {
        
        return .init(fieldName: fieldName, fieldValue: fieldValue, fieldTitle: fieldTitle, svgImage: svgImage)
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, type: type.rawValue, additionalItems: [])
    }
}

private extension UtilityPaymentProvider {
    
    var `operator`: UtilityPaymentOperator {
        
        return .init(id: id, inn: inn, title: title, icon: icon, type: type)
    }
}

private extension InitiateAnywayPaymentDomain.Failure
where Operator == UtilityPaymentProvider {
    
    var navigation: PaymentProviderPickerDomain.Navigation {
        
        switch self {
        case let .operatorFailure(utilityPaymentOperator):
            return .destination(.payment(.failure(.operatorFailure(utilityPaymentOperator))))
            
        case let .serviceFailure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                return .destination(.payment(.failure(.serviceFailure(.connectivityError))))
                
            case let .serverError(message):
                return .destination(.payment(.failure(.serviceFailure(.serverError(message)))))
            }
        }
    }
}

private extension AnywayFlowState.Status.Outside {
    
    var notifyEvent: PaymentProviderPickerDomain.FlowDomain.NotifyEvent {
        
        switch self {
        case .main:     return .select(.outside(.main))
        case .payments: return .select(.outside(.payments))
        }
    }
}
