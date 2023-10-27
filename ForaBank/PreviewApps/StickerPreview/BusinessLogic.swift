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
    
    private let dictionaryService: RemoteService<Operation, Operation>
    private let transfer: Transfer
    
    private let reduce: Reducer.Reduce
    
    public init(
        dictionaryService: RemoteService<Operation, Operation>,
        transfer: @escaping Transfer,
        reduce: @escaping Reducer.Reduce
    ) {
        self.dictionaryService = dictionaryService
        self.transfer = transfer
        self.reduce = reduce
    }
}

extension BusinessLogic {
    
    func operationResult(
        operation: Operation,
        event: Event,
        completion: @escaping (OperationResult) -> Void
    ) {
        
        let result: OperationResult = reduce(
            operation: operation,
            event: event,
            completion: completion
        )
        
        completion(result)
    }
}

extension BusinessLogic {
    
    //TODO: rename process
    func reduce(
        operation: Operation,
        event: Event,
        completion: @escaping (OperationResult) -> Void
    ) -> OperationResult {
        
        switch event {
        case let .select(selectEvent):
            
            switch selectEvent {
            case let .chevronTapped(parameter):
                
                switch parameter.state {
                case let .idle(idleViewModel):
                    
                    let updateSelect = parameter.updateSelect(
                        parameter: parameter,
                        idleViewModel: idleViewModel
                    )
                    
                    return .success(.operation(
                        operation.updateOperation(
                            operation: operation,
                            newParameter: .select(updateSelect)
                        ))
                    )
                    
                case let .selected(selectedViewModel):

                    let parameter = parameter.updateState(
                        iconName: selectedViewModel.iconName
                    )
                    
                    return .success(.operation(
                        operation.updateOperation(
                            operation: operation,
                            newParameter: .select(parameter)
                        ))
                    )
                    
                case .list(_):
                    
                    dictionaryService.process(operation) { result in
                        
                        switch result {
                        case let .success(operation):
                            completion(.success(.operation(operation)))
                            
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                    
                    return .success(.operation(operation))
                }
                
            case let .selectOption(id, parameter):
                
                let operation = selectOption(
                    id: id,
                    operation: operation,
                    parameter: parameter
                )
            
                return .success(.operation(operation))
                
            case let .filterOptions(text, parameter, filteredOptions):
                
                let newParameter = parameter.updateOptions(
                    parameter: parameter,
                    options: filteredOptions(text)
                )
                
                let parameters = operation.parameters.replaceParameterOptions(
                    newParameter: newParameter
                )
                
                return .success(.operation(.init(parameters: parameters)))
                
            case .openBranch:
                return .success(.operation(operation))
            }
            
        case .continueButtonTapped:
            
            transfer(.requestOTP) { result in
                
                switch result {
                case let .success(state):
                    completion(.success(state))
                    
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            
            return .success(.operation(operation))
            
        case let .product(productEvents):
            
            switch productEvents {
            case .chevronTapped:
                return .success(.operation(operation))
            case .selectProduct:
                return .success(.operation(operation))
            }
        default:
            return .success(.operation(operation))
        }
    }
    
    func selectOption(
        id: String,
        operation: Operation,
        parameter: Operation.Parameter.Select
    ) -> Operation {
        
        guard let option = parameter.options.first(where: { $0.id == id })
        else { return operation }
        
        let parameter = parameter.updateValue(
            parameter: parameter,
            option: option
        )
        
        let updateParameter = parameter.updateState(with: option)
        
        return operation.updateOperation(
            operation: operation,
            newParameter: .select(updateParameter)
        )
    }
}

// MARK: - Types

extension BusinessLogic {
    
    enum TransferEvent {
    
        case operation(Operation)
        case requestOTP
    }
    
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
