//
//  OperationStateViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import Combine

final class OperationStateViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let blackBoxGet: BlackBoxAPI.AsyncGet
//    let businessLogic: (State, Event) -> AnyPublisher<Result<State, Error>, Never>
    
    init(
        state: State = .operation(.init(parameters: [])),
        blackBoxGet: @escaping BlackBoxAPI.AsyncGet
    ) {
        self.state = state
        self.blackBoxGet = blackBoxGet
    }
    
    var scrollParameters: [Operation.Parameter] {
        
        operation?.parameters.filter({ $0.id != .amount }) ?? []
    }
    
    var amountParameter: Operation.Parameter? {
        
        operation?.parameters.first(where: { $0.id == .amount })
    }
    
    func event(_ event: Event) {
        
        guard let operation else {
            return
        }
        
        blackBoxGet((operation, event)) { result in
            
            switch result {
            case let .failure(error):
                self.handleAPIError(error)
                
            case let .success(state):
                self.state = state
            }
        }
    }
    
    private func handleAPIError(_ error: Error) {
        
        // TODO: setup error
    }
    
    func updateOperation(with parameters: [Operation.Parameter]) {
        
        self.state = .operation(.init(parameters: parameters))
    }
}

extension OperationStateViewModel {
    
    //TODO: extract from operation state view model
    enum State {
        
        case operation(Operation)
        case result(OperationResult)
    }
    
    struct OperationResult {
        
        let result: Result
        let title: String
        let description: String
        let amount: String
        
        enum Result {
            
            case success
            case waiting
            case failed
        }
    }
}

extension OperationStateViewModel {

    var operation: Operation? {
        
        guard case let .operation(operation) = state else {
            return nil
        }
        
        return operation
    }
}

/// A namespace.
enum BlackBoxAPI {}

extension BlackBoxAPI {
    
    typealias Request = (Operation, Event)
    typealias Success = OperationStateViewModel.State
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (Request, @escaping Completion) -> Void
}
