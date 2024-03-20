//
//  UtilityFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

public final class UtilityFlowEffectHandler<LastPayment, Operator, Service, StartPaymentResponse>
where Operator: Identifiable {
    
    private let loadPrepaymentOptions: LoadPrepaymentOptions
    private let loadServices: LoadServices
    private let optionsEffectHandle: OptionsEffectHandle
    private let startPayment: StartPayment
    
    public init(
        loadPrepaymentOptions: @escaping LoadPrepaymentOptions,
        loadServices: @escaping LoadServices,
        optionsEffectHandle: @escaping OptionsEffectHandle,
        startPayment: @escaping StartPayment
    ) {
        self.loadPrepaymentOptions = loadPrepaymentOptions
        self.loadServices = loadServices
        self.optionsEffectHandle = optionsEffectHandle
        self.startPayment = startPayment
    }
}

public extension UtilityFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiatePrepayment:
            self.initiatePrepayment(dispatch)
            
        case let .prepaymentOptions(effect):
            prepaymentOptionsEffectHandle(effect) {
                
                dispatch(.prepaymentOptions($0))
            }
            
        case let .select(select):
            self.select(select, dispatch)
        }
    }
}

public extension UtilityFlowEffectHandler {
    
    typealias LoadPrepaymentOptionsResponse = ([LastPayment], [Operator])
    typealias LoadPrepaymentOptionsResult = Result<LoadPrepaymentOptionsResponse, Error>
    typealias LoadPrepaymentOptionsCompletion = (LoadPrepaymentOptionsResult) -> Void
    typealias LoadPrepaymentOptions = (@escaping LoadPrepaymentOptionsCompletion) -> Void
    
    typealias LoadServicesPayload = Operator
    typealias LoadServicesResult = Result<[Service], Error>
    typealias LoadServicesCompletion = (LoadServicesResult) -> Void
    typealias LoadServices = (LoadServicesPayload, @escaping LoadServicesCompletion) -> Void
    
    typealias OptionsEvent = PrepaymentOptionsEvent<LastPayment, Operator>
    typealias OptionsEffect = PrepaymentOptionsEffect<Operator>
    typealias OptionsDispatch = (OptionsEvent) -> Void
    typealias OptionsEffectHandle = (OptionsEffect, @escaping OptionsDispatch) -> Void
    
    enum StartPaymentPayload {
        
        case withLastPayment(LastPayment)
        case withService(Service, for: Operator)
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
    
    func initiatePrepayment(
        _ dispatch: @escaping Dispatch
    ) {
        loadPrepaymentOptions {
            
            switch $0 {
            case .failure:
                dispatch(.prepaymentLoaded(.failure))
                
            case let .success((lastPayments, operators)):
                if operators.isEmpty {
                    dispatch(.prepaymentLoaded(.failure))
                } else {
                    dispatch(.prepaymentLoaded(.success(lastPayments, operators)))
                }
            }
        }
    }
    
    func prepaymentOptionsEffectHandle(
        _ optionEffect: OptionsEffect,
        _ dispatch: @escaping OptionsDispatch
    ) {
        optionsEffectHandle(optionEffect, dispatch)
    }
    
    func select(
        _ select: Effect.Select,
        _ dispatch: @escaping Dispatch
    ) {
        switch select {
        case let .last(lastPayment):
            startPayment(.withLastPayment(lastPayment)) {
                
                dispatch(.paymentStarted($0))
            }
            
        case let .operator(`operator`):
            self.select(`operator`, dispatch)
            
        case let .service(service, for: `operator`):
            startPayment(.withService(service, for: `operator`)) {
                
                dispatch(.paymentStarted($0))
            }
        }
    }
    
    func select(
        _ `operator`: Operator,
        _ dispatch: @escaping Dispatch
    ) {
        loadServices(`operator`) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case .failure:
                dispatch(.selectFailure(`operator`))
                
            case let .success(services):
                handle(services, for: `operator`, dispatch)
            }
        }
    }
    
    func handle(
        _ services: [Service],
        for `operator`: Operator,
        _ dispatch: @escaping Dispatch
    ) {
        switch (services.count, services.first) {
        case (0, .none):
            dispatch(.selectFailure(`operator`))
            
        case let (1, .some(service)):
            startPayment(.withService(service, for: `operator`)) {
                
                dispatch(.paymentStarted($0))
            }
            
        default:
            dispatch(.servicesLoaded(services))
        }
    }
}
