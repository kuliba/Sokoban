//
//  RootViewModelFactory+makePaymentProviderPicker.swift
//  Vortex
//
//  Created by Igor Malyarov on 03.12.2024.
//

import Combine
import PayHub
import RemoteServices

typealias StandardSelectedCategoryDestination = Result<PaymentProviderPickerDomain.Binder, FailedPaymentProviderPicker>

final class FailedPaymentProviderPicker: Error {}

extension RootViewModelFactory {
    
    @inlinable
    func makePaymentProviderPicker(
        for category: ServiceCategory,
        completion: @escaping (StandardSelectedCategoryDestination) -> Void
    ) {
        makePaymentProviderPicker(
            for: category,
            nanoServices: makeNanoServices(for: category),
            completion: completion
        )
    }
    
    @inlinable
    func makePaymentProviderPicker(
        for category: ServiceCategory,
        nanoServices: StandardNanoServices,
        completion: @escaping (StandardSelectedCategoryDestination) -> Void
    ) {
        let composer = StandardSelectedCategoryGetNavigationComposer(
            nanoServices: nanoServices
        )
        
        composer.makeDestination(category: category) {
            
            completion($0)
            _ = composer
        }
    }
    
    private func makeNanoServices(
        for category: ServiceCategory
    ) -> StandardNanoServices {
        
        return .init(
            loadLatest: { [weak self] in
                
                self?.loadLatestPayments(for: category, completion: $0)
            },
            loadOperators: { [weak self] in
                
                self?.loadOperatorsForCategory(category: category, completion: $0)
            },
            makeFailure: { $0(.init()) },
            makeSuccess: { [weak self] payload, completion in
                
                guard let self else { return }
                
                completion(makePaymentProviderPicker(payload: payload))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, UtilityPaymentProvider, PaymentProviderPickerDomain.Binder, FailedPaymentProviderPicker>
    
    @inlinable
    func makePaymentProviderPicker(
        payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Binder {
        
        let content = makeContent(with: payload)
        let flow = makeFlow()
        
        return .init(
            content: content,
            flow: flow,
            bind: { _,_ in [] }
        )
    }
    
    typealias MakeSelectedCategorySuccessPayload = PayHub.MakeSelectedCategorySuccessPayload<ServiceCategory, Latest, UtilityPaymentProvider>
    
    // MARK: - Content
    
    private func makeContent(
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
    
    // MARK: - Flow
    
    private func makeFlow() -> PaymentProviderPickerDomain.Flow {
        
        let flowReducer = PaymentProviderPickerDomain.FlowReducer()
        let flowEffectHandler = PaymentProviderPickerDomain.FlowEffectHandler(
            microServices: .init(
                initiatePayment: initiateAnywayPayment,
                makeDetailPayment: makeDetailPayment,
                processProvider: processProvider
            )
        )
        
        return .init(
            initialState: .init(),
            reduce: flowReducer.reduce(_:_:),
            handleEffect: flowEffectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
    }
    
    @inlinable
    func initiateAnywayPayment(
        latest: Latest,
        notify: @escaping PaymentProviderPickerDomain.FlowEffectHandler.MicroServices.Notify,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        initiateAnywayPayment(
            source: .latest(latest.latest),
            notify: { event in
                switch event {
                case .main:
                    notify(.select(.main))
                    
                case .payments:
                    notify(.select(.goToPayments))
                }
            },
            completion: completion
        )
    }
    
    @inlinable
    func initiateAnywayPayment(
        source: AnywayPaymentSourceParser.Source,
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        initiateAnywayPayment(source) {
            
            switch $0 {
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    completion(.backendFailure(.connectivity("connectivity failure")))
                    
                case let .serverError(message):
                    completion(.backendFailure(.server(message)))
                }
                
            case let .success(transaction):
                completion(self.makeCompletion(
                    transaction: transaction,
                    notify: notify
                ))
            }
        }
    }
    
    @inlinable
    func makeDetailPayment(
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        completion(.detailPayment(.init(
            model: self.model,
            service: .requisites,
            scheduler: self.schedulers.main
        )))
    }
    
    @inlinable
    func processProvider(
        provider: PaymentProviderPickerDomain.Provider,
        notify: @escaping PaymentProviderPickerDomain.FlowEffectHandler.MicroServices.Notify,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        processProvider(
            select: (.operator(provider), provider.type),
            notify: { event in
                
                switch event {
                case .main:
                    notify(.select(.main))
                    
                case .payments:
                    notify(.select(.goToPayments))
                }
            },
            completion: completion
        )
    }
    
    @inlinable
    func processProvider(
        select: (PrepaymentSelect, ServiceCategory.CategoryType),
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void,
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        processSelection(select: select) { [weak self] in
            
            guard let self else {
                
                return completion(.payment(.failure(.serviceFailure(.connectivityError))))
            }
            
            switch $0 {
            case let .failure(failure):
                switch failure {
                case let .operatorFailure(utilityPaymentOperator):
                    completion(.payment(.failure(.operatorFailure(utilityPaymentOperator))))
                    
                case let .serviceFailure(serviceFailure):
                    switch serviceFailure {
                    case .connectivityError:
                        completion(.payment(.failure(.serviceFailure(.connectivityError))))
                        
                    case let .serverError(message):
                        completion(.payment(.failure(.serviceFailure(.serverError(message)))))
                    }
                }
                
            case let .success(success):
                switch success {
                case let .services(multi, for: utilityPaymentOperator):
                    completion(.payment(.success(.services(multi, for: utilityPaymentOperator))))
                    
                case let .startPayment(transaction):
                    completion(makeCompletion(
                        transaction: transaction,
                        notify: notify
                    ))
                }
            }
        }
    }
    
    func makeCompletion(
        transaction: AnywayTransactionState.Transaction,
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void
    ) -> (PaymentProviderPickerDomain.Navigation) {
        
        let flowModel = makeAnywayFlowModel(transaction: transaction)
        let cancellable = flowModel.$state
            .compactMap(\.outside)
            .sink { notify($0) }
        
        return .payment(.success(
            .startPayment(.init(
                model: flowModel,
                cancellable: cancellable
            ))
        ))
    }
}

// MARK: - Adapters

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
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, type: type, additionalItems: additionalItems?.map(\.additional) ?? [])
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service.AdditionalItem {
    
    var additional: RemoteServices.ResponseMapper.LatestServicePayment.AdditionalItem {
        
        return .init(fieldName: fieldName, fieldValue: fieldValue, fieldTitle: fieldTitle, svgImage: svgImage)
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, type: type, additionalItems: [])
    }
}
