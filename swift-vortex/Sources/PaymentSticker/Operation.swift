//
//  Operation.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public struct Operation: Hashable {
    
    let state: State
    public var parameters: [Parameter]
    
    public enum State {
        
        case process
        case userInteraction
    }
    
    public init(
        state: State = .userInteraction,
        parameters: [Operation.Parameter]
    ) {
        self.state = state
        self.parameters = parameters
    }
}

public extension Operation {
    
    enum Parameter: Hashable {
        
        case tip(Tip)
        case sticker(Sticker)
        case select(Select)
        case productSelector(ProductSelector)
        case amount(Amount)
        case input(Input)
    }
}

//MARK: Helpers

extension Operation {
    
    enum OperationStage {
        
        case start
        case process
        case code
    }
    
    var operationStage: OperationStage {
        
        if self.parameters.count == 0 {
            return .start
            
        } else if let _ = self.parameters.first(where: { $0.id == .input }) {
            
            return .code
        } else {
            
            return .process
        }
    }
}

extension [Operation.Parameter] {
    
    var amountSticker: String? {
        
        switch self.first(where: { $0.id == .amount }) {
        case let .amount(amount):
            return amount.value
            
        default:
            return nil
        }
    }
    
    var amount: Decimal? {
        
        switch self.first(where: { $0.id == .amount }) {
        case let .amount(amount):
            return Decimal.init(string: amount.value)
            
        default:
            return nil
        }
    }
    
    var productID: String? {
        
        let productSelector = self.first(where: { $0.id == .productSelector })
        
        switch productSelector {
        case let .productSelector(product):
            return product.selectedProduct.id.description
        default:
            return nil
        }
    }
    
    var deliveryToOffice: Bool? {
        
        let transferType = self.first(where: { $0.id == .transferType })
        switch transferType {
        case let .select(select):
            if select.value == "typeDeliveryOffice" {
                return true
                
            } else {
                
                return false
            }
            
        default:
            return nil
        }
    }
    
    var officeID: String? {
        
        let branches = self.first(where: { $0.id == .branches })
        
        switch branches {
        case let .select(select):
            if select.id == .officeSelector,
               let value = select.value {
            
                return value
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
    
    var cityID: Int? {
        
        let city = self.first(where: { $0.id == .city })
        
        switch city {
        case let .select(select):
            
            if select.id == .citySelector,
               let value = select.value {
            
                return Int(value)
            } else {
                return nil
            }
        
        default:
            return nil
        }
    }
}

extension Operation {

    public var isOperationComplete: Bool {
        
        var complete: Bool = true
         
        for parameter in parameters {
            switch parameter {
            case let .select(select):
                if select.value == nil {
                    
                    complete = false
                }
                
            case let .productSelector(product):
                
                let banner = self.parameters.first(where: { $0.id == .sticker })
                
                switch banner {
                case let .sticker(banner):
                    
                    if let minAmount = banner.options.map({ $0.price }).min(),
                       product.selectedProduct.balance < minAmount {

                        complete = false
                    }
                    
                default: break
                }
                
            case .amount:
                let parameters = self.parameters.first(where: { $0.id == .input })
                
                switch parameters {
                case let .input(input):
                    
                    if input.value.count < 6 {
                        
                        return false
                    } else {
                        return true
                    }
                    
                default: break
                }
                
            default: break
            }
        }
        
        return complete
    }
    
    func containsParameter(_ parameter: Operation.Parameter) -> Bool {
        
        self.parameters.contains(where: { $0.id.rawValue == parameter.id.rawValue })
    }
}

extension [Operation.Parameter] {
    
    func getParameterTransferType() -> Operation.Parameter.Select? {
    
        switch self.first(where: { $0.id == .transferType }) {
        case let .select(select):
            return select
        default:
            return nil
        }
    }
    
    func getParameterIndex(with id: String) -> Index? {
        
        return self.firstIndex(where: { $0.id.rawValue == id })
    }
    
    func replaceParameter(
        newParameter: Operation.Parameter
    ) -> [Operation.Parameter] {
        
        guard let index = self.getParameterIndex(with: newParameter.id.rawValue)
        else { return self }
        
        var parameters = self
        parameters[index] = newParameter
        return parameters
    }
    
    func replaceParameterOptions(
        newParameter: Operation.Parameter.Select
    ) -> [Operation.Parameter] {
        
        guard let index = self.getParameterIndex(with: newParameter.id.rawValue)
        else { return self }
        
        var parameters = self
        parameters[index] = .select(newParameter)
        return parameters
    }
}

public extension Operation {
    
    func updateOperation(
        operation: Operation,
        newParameter: Operation.Parameter
    ) -> Operation {
        
        var operation = operation
        if containsParameter(newParameter) {
            
            operation.parameters = operation.parameters.replaceParameter(
                newParameter: newParameter
            )
            
        } else {
            operation.parameters.append(newParameter)
        }
        
        return operation
    }
}

public extension Operation.Parameter.Select {
    
    typealias ParameterSelect = Operation.Parameter.Select
    typealias SelectOption = Operation.Parameter.Select.Option
    
    func updateValue(
        parameter: ParameterSelect,
        option: SelectOption
    ) -> Self {
        
        ParameterSelect(
            id: parameter.id,
            value: option.id,
            title: parameter.title,
            placeholder: parameter.placeholder,
            options: parameter.options,
            staticOptions: parameter.staticOptions,
            state: .selected(.init(
                title: parameter.title,
                placeholder: option.name,
                name: option.name,
                iconName: option.iconName
            ))
        )
    }
}
