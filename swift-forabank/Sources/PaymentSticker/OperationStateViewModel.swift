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
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("otpCode"), object: nil)
    }
    
    public var scrollParameters: [Operation.Parameter] {
        
        operation?.parameters.filter({ $0.id != .amount }) ?? []
    }
    
    public var amountParameter: Operation.Parameter? {
        
        operation?.parameters.first(where: { $0.id == .amount })
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        let otp = notification.userInfo?["otp"] as? String
     
        guard let input = self.operation?.parameters.first(where: { $0.id == .input }) else { return }
        
        switch input {
        case let .input(input):
            
            guard let operation = operation, let otp else { return }
            
            let newOperation = self.operation?.updateOperation(
                operation: operation,
                newParameter: .input(.init(
                    value: otp,
                    title: input.title,
                    warning: input.warning
                ))
            )
            
            guard let newOperation else { return }
            
            DispatchQueue.main.async {
                
                self.event(.input(.valueUpdate(otp)))
            }
            
        default: return
        }
    }
    
    public var isOperationComplete: Bool {
    
        guard let parameters = operation?.parameters else {
            return false
        }
        
        var complete: Bool = true
         
        for parameter in parameters {
            switch parameter {
            case let .select(select):
                if select.value == nil {
                    
                    complete = false
                }
                
            case let .productSelector(product):
                
                let banner = operation?.parameters.first(where: { $0.id == .sticker })
                
                switch banner {
                case let .sticker(banner):
                    
                    if let minAmount = banner.options.map({ $0.price }).min(),
                       Double(product.selectedProduct.balance) ?? 0 < minAmount {

                        complete = false
                    }
                    
                default: break
                }
                
            default: break
            }
        }
        
        return complete
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
    public enum State {
        
        case operation(Operation)
        case result(OperationResult)
    }
    
    public struct OperationResult {
        
        public let result: Result
        public let title: String
        public let description: String
        public let amount: String
        public let paymentID: PaymentID
        
        public init(
            result: Result,
            title: String,
            description: String,
            amount: String,
            paymentID: PaymentID
        ) {
            self.result = result
            self.title = title
            self.description = description
            self.amount = amount
            self.paymentID = paymentID
        }
        
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
