//
//  FastPaymentsSettingsReducer.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

public final class FastPaymentsSettingsReducer {
    
    private let bankDefaultReduce: BankDefaultReduce
    private let consentListReduce: ConsentListReduce
    private let contractReduce: ContractReduce
    private let productsReduce: ProductsReduce
    
    public init(
        bankDefaultReduce: @escaping BankDefaultReduce,
        consentListReduce: @escaping ConsentListReduce,
        contractReduce: @escaping ContractReduce,
        productsReduce: @escaping ProductsReduce
    ) {
        self.bankDefaultReduce = bankDefaultReduce
        self.consentListReduce = consentListReduce
        self.contractReduce = contractReduce
        self.productsReduce = productsReduce
    }
}

public extension FastPaymentsSettingsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .appear:
            (state, effect) = handleAppear(state)
            
        case let .loadSettings(settings):
            state = handleLoadedSettings(settings)
            
        case .resetStatus:
            state = resetStatus(state)
            
        case let .bankDefault(bankDefault):
            (state, effect) = bankDefaultReduce(state, bankDefault)
            
#warning("add tests")
        case let .consentList(consentList):
            (state, effect) = reduce(state, consentList)
            
        case let .contract(contract):
            let (newState, contractEffect) = contractReduce(state, contract)
            (state, effect) = (newState, contractEffect.map(Effect.contract))
            
        case let .products(products):
            (state, effect) = productsReduce(state, products)
            
        case let .subscriptions(subscriptions):
#warning("add tests")
            (state, effect) = reduce(state, with: subscriptions)
        }
        
        return (state, effect)
    }
}

public extension FastPaymentsSettingsReducer {
    
    typealias BankDefaultReduce = (State, Event.BankDefault) -> (State, Effect?)
    typealias ConsentListReduce = (ConsentListState, ConsentListEvent) -> (ConsentListState, ConsentListEffect?)
    typealias ContractReduce = (State, Event.Contract) -> (State, Effect.Contract?)
    typealias ProductsReduce = (State, Event.Products) -> (State, Effect?)
    
    typealias State = FastPaymentsSettingsState
    typealias Event = FastPaymentsSettingsEvent
    typealias Effect = FastPaymentsSettingsEffect
}

private extension FastPaymentsSettingsReducer {
    
    func handleAppear(
        _ state: State
    ) -> (State, Effect) {
        
        var state = state
        state.status = .inflight
        
        return (state, .getSettings)
    }
    
    func reduce(
        _ state: State,
        _ event: ConsentListEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.userPaymentSettings {
        case var .contracted(contractDetails):
            let (consentList, consentListEffect) = consentListReduce(contractDetails.consentList, event)
            contractDetails.consentList = consentList
            state.userPaymentSettings = .contracted(contractDetails)
            effect = consentListEffect.map(Effect.consentList)
            
        case .none, .missingContract, .failure:
            break
        }
        
        return (state, effect)
    }
    
    func handleLoadedSettings(
        _ userPaymentSettings: UserPaymentSettings
    ) -> State {
        
        .init(userPaymentSettings: userPaymentSettings)
    }
    
#warning("add tests")
    func reduce(
        _ state: State,
        with event: FastPaymentsSettingsEvent.Subscriptions
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .getC2BSubButtonTapped:
            state.status = .inflight
            effect = .getC2BSub
            
        case let .loaded(getC2BSubResult):
            state = reduce(state, with: getC2BSubResult)
        }
        
        return (state, effect)
    }
    
#warning("add tests")
    func reduce(
        _ state: State,
        with getC2BSubResult: FastPaymentsSettingsEvent.GetC2BSubResult
    ) -> State {
        
        var state = state
        
        switch getC2BSubResult {
        case let .success(getC2BSubResponse):
            state.status = .getC2BSubResponse(getC2BSubResponse)
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                state.status = nil
                
            case let .serverError(message):
                state.status = .serverError(message)
            }
        }
        
        return state
    }
    
    func resetStatus(
        _ state: State
    ) -> State {
        
        var state = state
        state.status = nil
        
        return state
    }
}
