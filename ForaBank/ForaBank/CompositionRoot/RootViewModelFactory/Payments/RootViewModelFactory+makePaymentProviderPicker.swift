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
    ) -> NanoServices {
        
        let getLatestPayments = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetAllLatestPaymentsV3Request,
            mapResponse: RemoteServices.ResponseMapper.mapGetAllLatestPaymentsResponse
        )
        
        return .init(
            loadLatest: { getLatestPayments([category.name], $0) },
            loadOperators: {
                
                self.loadOperatorsForCategory(category: category, completion: $0)
            },
            makeFailure: { $0(.init()) },
            makeSuccess: { payload, completion in
                
                completion(self.makePaymentProviderPicker(payload: payload))
            }
        )
    }
    
    private typealias NanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, PaymentServiceOperator, PaymentProviderPickerDomain.Binder, FailedPaymentProviderPicker>
    
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
    
    typealias MakeSelectedCategorySuccessPayload = PayHub.MakeSelectedCategorySuccessPayload<ServiceCategory, Latest, PaymentServiceOperator>
    
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
            nanoServices: .init(loadOperators: loadOperators)
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
    
    func makeFlow(
        with payload: MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Flow {
        
        let flowReducer = PaymentProviderPickerDomain.FlowReducer()
        let flowEffectHandler = PaymentProviderPickerDomain.FlowEffectHandler(
            microServices: .init(
                initiatePayment: { latest, completion in
                    
                    completion(.backendFailure(.connectivity("connectivity failure")))
                },
                makeDetailPayment: {
                    
                    $0(.detailPayment(.init(
                        model: self.model,
                        service: .requisites,
                        scheduler: self.schedulers.main
                    )))
                },
                processProvider: { provider, completion in
                    
                    completion(.payment(()))
                }
            )
        )
        
        return .init(
            initialState: .init(),
            reduce: flowReducer.reduce(_:_:),
            handleEffect: flowEffectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
    }
}
