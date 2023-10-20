//
//  OperationViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import Combine

final class OperationViewModel: ObservableObject {
    
    @Published private(set) var operation: Operation
    
    private let blackBoxGet: BlackBoxAPI.AsyncGet
    //    private let eventSubject = PassthroughSubject<Event, Never>()
    
    init(
        operation: Operation = .init(parameters: []),
        blackBoxGet: @escaping BlackBoxAPI.AsyncGet
        //        blackBoxGet: @escaping (Operation, Event) -> AnyPublisher<Operation, Never>
    ) {
        self.operation = operation
        self.blackBoxGet = blackBoxGet
        
        //        $operation
        //            .combineLatest(eventSubject)
        ////            .removeDuplicates()
        //            .receive(on: DispatchQueue.main)
        //            .flatMap(blackBoxGet)
        //            .assign(to: &$operation)
        
    }
    
    var scrollParameters: [Operation.Parameter] {
        
        operation.parameters.filter({ $0.id != "amount" })
    }
    
    var amountParameter: Operation.Parameter? {
        
        // TODO: get rid of stringly API - replace with strong type
        operation.parameters.first(where: { $0.id == "amount" })
    }
    
    func event(_ event: Event) {
        
        blackBoxGet((operation, event)) { result in
            
            switch result {
            case let .failure(error):
                self.handleAPIError(error)
                
            case let .success(operation):
                //                self.updateOperation(with: parameters)
                self.operation = operation
            }
        }
        //        eventSubject.send(event)
    }
    
    private func handleAPIError(_ error: Error) {
        
        // TODO: implement
        //        self.operation.parameters.append(.hint(.init()))
        
    }
    
    private func updateOperation(with parameters: [Operation.Parameter]) {
        
        self.operation.parameters = parameters
    }
}

/// A namespace.
enum BlackBoxAPI {}

extension BlackBoxAPI {
    
    typealias Request = (Operation, Event)
    typealias Success = Operation
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (Request, @escaping Completion) -> Void
}

struct BusinessLogic {
    
}
