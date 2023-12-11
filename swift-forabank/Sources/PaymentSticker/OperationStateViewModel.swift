//
//  OperationStateViewModel.swift
//
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import Combine

final public class OperationStateViewModel: ObservableObject {
    
    @Published public var state: State
    
    private let blackBoxGet: BlackBoxAPI.AsyncGet
    
    public init(
        state: State = .operation(.init(parameters: [])),
        blackBoxGet: @escaping BlackBoxAPI.AsyncGet
    ) {
        self.state = state
        self.blackBoxGet = blackBoxGet
        event(.continueButtonTapped(.continue))
    }
    
    public func event(_ event: Event) {
        
        guard let operation else {
            return
        }
        
        blackBoxGet((operation, event)) { result in
            
            DispatchQueue.main.async {
             
                switch result {
                case let .failure(error):
                    self.handleAPIError(error)
                    
                case let .success(state):
                    self.state = state
                }
            }
        }
    }
    
    private func handleAPIError(_ error: Error) {
        
        // TODO: setup error
    }
}

//MARK: Helpers

extension OperationStateViewModel {
    
    public var operation: Operation? {
        
        guard case let .operation(operation) = state else {
            return nil
        }
        
        return operation
    }
}

extension OperationStateViewModel {
    
    public enum State: Equatable {
        
        case operation(Operation)
        case result(OperationResult)
    }
}

/// A namespace.
public enum BlackBoxAPI {}

public extension BlackBoxAPI {
    
    typealias Request = (Operation, Event)
    typealias Success = OperationStateViewModel.State
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (Request, @escaping Completion) -> Void
}
