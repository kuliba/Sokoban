//
//  BusinessLogic.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 23.10.2023.
//

import Foundation
import Combine
import GenericRemoteService

final class BusinessLogic {
    
    typealias Option = Operation.Parameter.Select.Option
    typealias OperationResult = Result<OperationStateViewModel.State, Error>
    typealias Completion = (OperationResult) -> Void
    typealias Load = (Operation, Event, @escaping Completion) -> AnyPublisher<OperationResult, Never>
    typealias Transfer = (TransferEvent, @escaping Completion) -> Void
    
    private let dictionaryService: RemoteService<Operation, Error>
    private let transfer: Transfer
    
    enum TransferEvent {
    
        case operation(Operation)
        case requestOTP
    }
    
    private let reduce: Reducer.Reduce
    
    //TODO: remove operation state from `OperationStateViewModel`
    private let operationSubject = PassthroughSubject<OperationResult, Never>()
    
    public init(
        dictionaryService: RemoteService<Operation, Error>,
        transfer: @escaping Transfer,
        reduce: @escaping Reducer.Reduce
    ) {
        self.dictionaryService = dictionaryService
        self.transfer = transfer
        self.reduce = reduce
    }
}

extension BusinessLogic {
    
    func operationResult(operation: Operation, event: Event, completion: @escaping (OperationResult) -> Void) {
        
        //TODO:
        //1. reduce operation with event -> OperationResult
        let result: OperationResult = { fatalError() }()
        //2. complete with result
        completion(result)
    }
    
    func operationResult(operation: Operation, event: Event) -> AnyPublisher<OperationResult, Never> {
        
        reduce(operation: operation, event: event)
        
        return operationSubject.eraseToAnyPublisher()
    }
}

extension BusinessLogic {

    func reduce(operation: Operation, event: Event) {
        
        switch event {
        case let .select(selectEvent):
            
            switch selectEvent {
            case .chevronTapped:
                
                dictionaryService.process(operation) { result in
                    
                    switch result {
                    case let .success(parameters):
                            break
//                        let operation = updateOperation(operation, with: parameters)
//                        operationSubject.send(.success(.operation(operation)))
                        
                    case let .failure(error):
                        break
                    }
                }
                
            case .selectOption:
                break
                
            case .filterOptions:
                break
                
            case .openBranch:
                break
            }
            
        case .continueButtonTapped:
            break
        
        case let .product(productEvents):
            
            switch productEvents {
            case .chevronTapped:
                break
            case .selectProduct:
                break
            }
            
        default: break
        }
    }
}

// MARK: - Types

extension BusinessLogic {
    
    public enum State {
        
        case local(OperationResult)
        case remote(OperationResult)
    }
    
    public enum Action {
        
        case loadLocal(Result<OperationResult, Error>)
        case loadRemote(Swift.Result<OperationResult, Error>)
    }
    
    public struct Reducer {
        
        public typealias Reduce = (Operation, Event) -> State
        
        public let reduce: Reduce
        
        public init(reduce: @escaping Reduce) {
            
            self.reduce = reduce
        }
    }
}
