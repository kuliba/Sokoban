//
//  RootViewModelFactory+makePaymentProviderPicker.swift
//  ForaBank
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
        let nanoServices = makeNanoServices(for: category)
        makePaymentProviderPicker(for: category, nanoServices: nanoServices, completion: completion)
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
        
        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        
        return .init(
            loadLatest: { getLatestPayments([category.type.name], $0) },
            loadOperators: {
                
                self.loadOperatorsForCategory(category: category, completion: $0)
            },
            makeFailure: { $0(.init()) },
            makeSuccess: { payload, completion in
                
                completion(self.makePaymentProviderPicker(payload: payload))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, UtilityPaymentProvider, PaymentProviderPickerDomain.Binder, FailedPaymentProviderPicker>
    
    @inlinable
    func makePaymentProviderPicker(
        payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Binder {
        
        let content = makeContent(with: payload)
        let flow = makeFlow(with: payload)
        
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
    
    private func makeFlow(
        with payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Flow {
        
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
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        let anywayFlowComposer = makeAnywayFlowComposer()
        
        initiateAnywayPayment(.latest(latest.latest)) {
            
            switch $0 {
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    completion(.backendFailure(.connectivity("connectivity failure")))
                    
                case let .serverError(message):
                    completion(.backendFailure(.server(message)))
                }
                
            case let .success(transaction):
                completion(.payment(.success(.anywayPayment(
                    anywayFlowComposer.compose(transaction: transaction)
                ))))
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
        completion: @escaping (PaymentProviderPickerDomain.Navigation) -> Void
    ) {
        let anywayFlowComposer = makeAnywayFlowComposer()
        
        processSelection(select: (.operator(provider), .init(string: provider.type) ?? .housingAndCommunalService)) {
            
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
                    completion(.payment(.success(.anywayPayment(
                        anywayFlowComposer.compose(transaction: transaction)
                    ))))
                }
            }
        }
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
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref, additionalItems: additionalItems?.map(\.additional) ?? [])
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.Service.AdditionalItem {
    
    var additional: RemoteServices.ResponseMapper.LatestServicePayment.AdditionalItem {
        
        return .init(fieldName: fieldName, fieldValue: fieldValue, fieldTitle: fieldTitle, svgImage: svgImage)
    }
}

private extension RemoteServices.ResponseMapper.LatestPayment.WithPhone {
    
    var latest: RemoteServices.ResponseMapper.LatestServicePayment {
        
        return .init(date: .init(timeIntervalSince1970: .init(date)), amount: amount ?? 0, name: name ?? "", md5Hash: md5Hash, puref: puref ?? "", additionalItems: [])
    }
}
