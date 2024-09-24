//
//  StandardSelectedCategoryDestinationNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import CombineSchedulers
import Foundation
import PayHub

final class StandardSelectedCategoryDestinationNanoServicesComposer {
    
    private let loadLatest: LoadLatest
    private let loadOperators: LoadOperators
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
        self.scheduler = scheduler
    }
    
    typealias LoadLatest = (ServiceCategory, @escaping (Result<[Latest], Error>) -> Void) -> Void
    
    typealias Operator = PaymentServiceOperator
    typealias LoadOperators = (ServiceCategory, @escaping (Result<[Operator], Error>) -> Void) -> Void
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
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, PaymentProviderPicker.Binder, FailedPaymentProviderPickerStub>
}

private extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func makePickerBinder(
        //        category: ServiceCategory,
        //        latest: [Latest],
        //        operators: [Operator]
        with payload: StandardNanoServices.MakeSuccessPayload
    ) -> PaymentProviderPicker.Binder {
        
        let content = makeContent(with: payload)
        let flow = makeFlow(with: payload)
        
        return .init(
            content: content,
            flow: flow,
            bind: { _,_ in [] }
        )
    }
    
    private func makeContent(
        with payload: StandardNanoServices.MakeSuccessPayload
    ) -> PaymentProviderPicker.Content {
        
        return .init(
            operationPicker: (),
            providerList: (),
            search: payload.category.hasSearch ? () : nil,
            cancellables: []
        )
    }
    
    private func makeFlow(
        with payload: StandardNanoServices.MakeSuccessPayload
    ) -> PaymentProviderPicker.Flow {
        
        let flowReducer = PaymentProviderPicker.FlowReducer()
        let flowEffectHandler = PaymentProviderPicker.FlowEffectHandler(
            microServices: .init(
                initiatePayment: { latest, completion in
                    
                    completion(.backendFailure(.connectivity("connectivity failure")))
                },
                makeDetailPayment: { completion in
                    
                    completion(.payment(()))
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
