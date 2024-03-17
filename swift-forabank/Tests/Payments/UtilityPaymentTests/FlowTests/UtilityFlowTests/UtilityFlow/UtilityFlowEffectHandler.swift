//
//  UtilityFlowEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment

final class UtilityFlowEffectHandler<LastPayment, Operator, Service, StartPaymentResponse> {
    
    private let load: Load
    private let loadServices: LoadServices
    private let startPayment: StartPayment
    
    init(
        load: @escaping Load,
        loadServices: @escaping LoadServices,
        startPayment: @escaping StartPayment
    ) {
        self.load = load
        self.loadServices = loadServices
        self.startPayment = startPayment
    }
}

extension UtilityFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            initiate(dispatch)
            
        case let .select(payload):
            switch payload {
            case let .last(lastPayment):
                startPayment(.last(lastPayment)) {
                    
                    dispatch(.paymentStarted($0))
                }
                
            case let .operator(`operator`):
                loadServices(`operator`) { [weak self] in
                    
                    guard let self else { return }
                    
                    switch $0 {
                    case .failure:
                        dispatch(.selectFailure(`operator`))
                        
                    case let .success(services):
                        switch (services.count, services.first) {
                        case (0, .none):
                            dispatch(.selectFailure(`operator`))
                        
                        case let (1, .some(service)):
                            startPayment(.service(service, for: `operator`)) {
                                
                                dispatch(.paymentStarted($0))
                            }
                            
                        default:
                            dispatch(.loadedServices(services))
                        }
                    }
                }
                
            case let .service(service, for: `operator`):
                startPayment(.service(service, for: `operator`)) {
                    
                    dispatch(.paymentStarted($0))
                }
            }
        }
    }
}

extension UtilityFlowEffectHandler {
    
    typealias LoadResponse = ([LastPayment], [Operator])
    typealias LoadResult = Result<LoadResponse, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias LoadServicesPayload = Operator
    typealias LoadServicesResult = Result<[Service], Error>
    typealias LoadServicesCompletion = (LoadServicesResult) -> Void
    typealias LoadServices = (LoadServicesPayload, @escaping LoadServicesCompletion) -> Void

    enum StartPaymentPayload {
        
        case last(LastPayment)
        case service(Service, for: Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentResponse, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator, Service>
}

extension UtilityFlowEffectHandler.StartPaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}

private extension UtilityFlowEffectHandler {
    
    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        load {
            
            switch $0 {
            case .failure:
                dispatch(.loaded(.failure))
                
            case let .success((lastPayments, operators)):
                if operators.isEmpty {
                    dispatch(.loaded(.failure))
                } else {
                    dispatch(.loaded(.success(lastPayments, operators)))
                }
            }
        }
    }
}
