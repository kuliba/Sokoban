//
//  PrePaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 09.03.2024.
//

public final class PrePaymentEffectHandler<LastPayment, Operator, Response, Service> {
    
    private let loadServices: LoadServices
    private let startPayment: StartPayment
    
    public init(
        loadServices: @escaping LoadServices,
        startPayment: @escaping StartPayment
    ) {
        self.loadServices = loadServices
        self.startPayment = startPayment
    }
}

public extension PrePaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            handleSelect(select, dispatch)
        }
    }
}

public extension PrePaymentEffectHandler {
    
    typealias LoadServicesPayload = Operator
    typealias LoadServicesResult = Result<[Service], Error>
    typealias LoadServicesCompletion = (LoadServicesResult) -> Void
    typealias LoadServices = (LoadServicesPayload, @escaping LoadServicesCompletion) -> Void
    
    enum StartPaymentPayload {
        
        case last(LastPayment)
        case service(Operator, Service)
    }
    
    typealias StartPaymentResult = Result<Response, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrePaymentEvent<LastPayment, Operator, Response, Service>
    typealias Effect = PrePaymentEffect<LastPayment, Operator, Service>
}

extension PrePaymentEffectHandler.StartPaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}

private extension PrePaymentEffectHandler {
    
    func handleSelect(
        _ select: Effect.Select,
        _ dispatch: @escaping Dispatch
    ) {
        switch select {
        case let .last(lastPayment):
            selectLastPayment(lastPayment, dispatch)
            
        case let .operator(`operator`):
            selectOperator(`operator`, dispatch)
            
        case let .service(`operator`, service):
            selectService(`operator`, service, dispatch)
        }
    }
    
    func selectLastPayment(
        _ lastPayment: LastPayment,
        _ dispatch: @escaping Dispatch
    ) {
        startPayment(.last(lastPayment)) { [weak self] in
            
            self?.handleStartPayment(result: $0, dispatch)
        }
    }
    
    func handleStartPayment(
        result: StartPaymentResult,
        _ dispatch: @escaping Dispatch
    ) {
        switch result {
        case let .failure(serviceFailure):
            dispatch(.paymentStarted(.failure(serviceFailure)))
            
        case let .success(response):
            dispatch(.paymentStarted(.success(response)))
        }
    }
    
    func selectOperator(
        _ `operator`: Operator,
        _ dispatch: @escaping Dispatch
    ) {
        loadServices(`operator`) { [weak self] in
            
            switch $0 {
            case .failure:
                dispatch(.loaded(.failure))
                
            case let .success(services):
                switch (services.first, services.count) {
                case (nil, _):
                    dispatch(.loaded(.failure))
                    
                case let (.some(service), 1):
                    self?.startPayment(.service(`operator`, service)) { [weak self] in
                        
                        self?.handleStartPayment(result: $0, dispatch)
                    }
                    
                default:
                    dispatch(.loaded(.list(`operator`, services)))
                }
            }
        }
    }
    
    func selectService(
        _ `operator`: Operator,
        _ service: Service,
        _ dispatch: @escaping Dispatch
    ) {
        startPayment(.service(`operator`, service)) { [weak self] in
            
            self?.handleStartPayment(result: $0, dispatch)
        }
    }
}
