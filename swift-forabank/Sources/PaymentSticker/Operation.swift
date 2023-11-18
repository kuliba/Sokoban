//
//  Operation.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public struct Operation {
    
    public var parameters: [Parameter]
    
    public init(
        parameters: [Operation.Parameter]
    ) {
        self.parameters = parameters
    }
}

public extension Operation {
    
    enum Parameter: Hashable {
        
        case tip(Tip)
        case sticker(Sticker)
        case select(Select)
        case product(Product)
        case amount(Amount)
        case input(Input)
    }
}

//MARK: Helpers

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
    
    public func replaceParameter(
        newParameter: Operation.Parameter
    ) -> [Operation.Parameter] {
        
        guard let index = self.getParameterIndex(with: newParameter.id.rawValue)
        else { return self }
        
        var parameters = self
        parameters[index] = newParameter
        return parameters
    }
    
    public func replaceParameterOptions(
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
        operation.parameters = operation.parameters.replaceParameter(
            newParameter: newParameter
        )
        
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
            state: .selected(.init(
                title: parameter.title,
                placeholder: option.name,
                name: option.name,
                iconName: option.iconName
            ))
        )
    }
}
