//
//  Operation.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

struct Operation {
    
    /// - Note: it would be much better to use something like [IdentifiedArray](https://github.com/pointfreeco/swift-identified-collections#introducing-identified-collections) to simplify access to array elements via ID.
    var parameters: [Parameter]
}

extension Operation {
    
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
    
    func getParameterIndex(with id: String) -> Index? {
        
        return self.firstIndex(where: { $0.id.rawValue == id })
    }
    
    func replaceParameter(newParameter: Operation.Parameter) -> [Operation.Parameter] {
        
        guard let index = self.getParameterIndex(with: newParameter.id.rawValue)
        else { return self }
        
        var parameters = self
        parameters[index] = newParameter
        return parameters
    }
}

extension Operation {
    
    func updateOperation(
        operation: Operation,
        newParameter: Operation.Parameter
    ) -> Operation {
        
        var operation = operation
        operation.parameters = operation.parameters.replaceParameter(newParameter: newParameter)
        
        return operation
    }
}
