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
    
    func updateOperation(with parameters: [Operation.Parameter]) {
        
        self.state = .operation(.init(parameters: parameters))
    }
}

//MARK: Helpers

extension OperationStateViewModel {
    
    var operation: Operation? {
        
        guard case let .operation(operation) = state else {
            return nil
        }
        
        return operation
    }
    
    public var scrollParameters: [Operation.Parameter] {
        
        operation?.parameters.filter({ $0.id != .amount }) ?? []
    }
    
    public var amountParameter: Operation.Parameter? {
        
        operation?.parameters.first(where: { $0.id == .amount })
    }
    
    public var product: Operation.Parameter.ProductSelector? {
        
        let product = operation?.parameters.first { $0.id == .productSelector }
        
        switch product {
        case let .productSelector(product):
            return product
            
        default:
            return nil
        }
    }
    
    public var banner: Operation.Parameter.Sticker? {
        
        let product = operation?.parameters.first { $0.id == .sticker }
        
        switch product {
        case let .sticker(sticker):
            return sticker
            
        default:
            return nil
        }
    }
    
    public var transferType: Operation.Parameter.Select? {
        
        let product = operation?.parameters.first { $0.id == .transferType }
        
        switch product {
        case let .select(select):
            return select
            
        default:
            return nil
        }
    }
    
    public func isOperationComplete() -> Bool {
        
        var complete: Bool = true
        
        guard let parameters = operation?.parameters else {
            return false
        }
    
        for parameter in parameters {
            
            if transferType?.id == .transferTypeSticker {
                
                if transferType?.value == "typeDeliveryCourier" {
                    
                    if let maxAmount = self.banner?.options.map({ $0.price }).max(),
                       Double(self.product?.selectedProduct.balance ?? "0") ?? 0 < maxAmount {
                        
                        return false
                    }
                } else if transferType?.value == "typeDeliveryOffice" {
                    
                    if let minAmount = self.banner?.options.map({ $0.price }).min(),
                       Double(self.product?.selectedProduct.balance ?? "0") ?? 0 < minAmount {
                        
                        complete = false
                    }
                }
            }
            
            switch parameter {
            case let .select(select):
                
                if select.value == nil {
                    
                    complete = false
                }
                
            default:
                break
            }
        }
        
        return complete
    }
}

extension OperationStateViewModel {
    
    public enum State {
        
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
