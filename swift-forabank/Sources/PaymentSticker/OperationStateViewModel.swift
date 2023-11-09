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
    
    public var scrollParameters: [Operation.Parameter] {
        
        operation?.parameters.filter({ $0.id != .amount }) ?? []
    }
    
    public var amountParameter: Operation.Parameter? {
        
        operation?.parameters.first(where: { $0.id == .amount })
    }
    
    public func event(_ event: Event) {
        
        guard let operation else {
            return
        }
        
        blackBoxGet((operation, event)) { result in
            
            switch result {
            case let .failure(error):
                self.handleAPIError(error)
                
            case let .success(state):
                
                if operation.parameters.contains(where: { $0.id == .input }) {
                    
                    self.state = .result(.init(
                        result: .success,
                        title: "Успешная заявка",
                        description: "Спасибо за заказ! В ближайшее время с вами свяжется наш курьер для уточнения места и времени доставки.",
                        amount: "790 Р"
                    ))
                    
                } else {
                    
                    self.state = state
                }
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
    public enum State {
        
        case operation(Operation)
        case result(OperationResult)
    }
    
    public struct OperationResult {
        
        public let result: Result
        public let title: String
        public let description: String
        public let amount: String
        
        public enum Result {
            
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
public enum BlackBoxAPI {}

public extension BlackBoxAPI {
    
    typealias Request = (Operation, Event)
    typealias Success = OperationStateViewModel.State
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (Request, @escaping Completion) -> Void
}
