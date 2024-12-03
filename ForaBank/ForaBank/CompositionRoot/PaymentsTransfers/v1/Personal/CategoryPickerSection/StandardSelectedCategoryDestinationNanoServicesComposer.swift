//
//  StandardSelectedCategoryDestinationNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import TextFieldModel
import UtilityServicePrepaymentCore

final class StandardSelectedCategoryDestinationNanoServicesComposer {
    
    private let loadLatest: LoadLatest
    private let loadOperators: LoadOperators
    private let makeMicroServices: MakeMicroServices
    private let model: Model
    private let observeLast: Int
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators,
        makeMicroServices: @escaping MakeMicroServices,
        model: Model,
        observeLast: Int = 10,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
        self.makeMicroServices = makeMicroServices
        self.model = model
        self.observeLast = observeLast
        self.scheduler = scheduler
    }
    
    typealias LoadLatest = (ServiceCategory, @escaping (Result<[Latest], Error>) -> Void) -> Void
    
    typealias Operator = PaymentServiceOperator
    typealias LoadOperators = (ServiceCategory, @escaping (Result<[Operator], Error>) -> Void) -> Void
    
    typealias MakeMicroServices = (ServiceCategory.CategoryType) -> MicroServices
    typealias MicroServices = PrepaymentPickerMicroServices<Operator>
}

extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func compose(
        category: ServiceCategory
    ) -> StandardNanoServices {
        
        let loadLatest = { self.loadLatest(category, $0) }
        let loadOperators = { self.loadOperators(category, $0) }
        
        return .init(
            loadLatest: loadLatest,
            loadOperators: loadOperators,
            makeFailure: { $0(.init()) },
            makeSuccess: { payload, completion in
                
                completion(self.makePickerBinder(with: payload))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, PaymentProviderPickerDomain.Binder, FailedPaymentProviderPickerStub>
}

private extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func makePickerBinder(
        with payload: StandardNanoServices.MakeSuccessPayload
    ) -> PaymentProviderPickerDomain.Binder {
        
        let content = makeContent(with: payload)
        let flow = makeFlow(with: payload)
        
        return .init(
            content: content,
            flow: flow,
            bind: { _,_ in [] }
        )
    }
}

// MARK: - Content

private extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func makeContent(
        with payload: StandardNanoServices.MakeSuccessPayload
    ) -> PaymentProviderPickerDomain.Content {
        
        let providerList = makeProviderList(with: payload)
        let search = payload.category.hasSearch ? makeSearch() : nil
        let cancellable = search?.$state
            .map { $0.text ?? "" }
            .debounce(for: .milliseconds(300), scheduler: scheduler)
            .sink { [weak providerList] in providerList?.event(.search($0)) }
        
        var cancellables = Set<AnyCancellable>()
        
        if let cancellable {
            
            cancellables.insert(cancellable)
        }
        
        return .init(
            title: payload.category.name,
            operationPicker: (),
            providerList: providerList,
            search: search,
            cancellables: cancellables
        )
    }
    
    private func makeProviderList(
        with payload: StandardNanoServices.MakeSuccessPayload
    ) -> PaymentProviderPickerDomain.ProviderList {
        
        let reducer = PaymentProviderPickerDomain.ProviderListReducer(
            observeLast: observeLast
        )
        let effectHandler = PaymentProviderPickerDomain.ProviderListEffectHandler(
            microServices: makeMicroServices(payload.category.type)
        )
        
        return .init(
            initialState: .init(
                lastPayments: payload.latest,
                operators: payload.operators,
                searchText: ""
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    private func makeSearch() -> RegularFieldViewModel {
        
        let placeholderText = "Наименование или ИНН"
        let searchReducer = TransformingReducer(
            placeholderText: placeholderText,
            transform: { $0 }
        )
        
        return .init(
            initialState: .placeholder(placeholderText),
            reducer: searchReducer,
            keyboardType: .default
        )
    }
}

// MARK: - Flow

private extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func makeFlow(
        with payload: StandardNanoServices.MakeSuccessPayload
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
                        scheduler: self.scheduler
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
            scheduler: scheduler
        )
    }
}
