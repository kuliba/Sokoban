//
//  ParameterViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation

public enum ParameterViewModel {
    
    case sticker(StickerViewModel)
    case tip(TipViewModel)
    case select(SelectViewModel)
    case product(ProductStateViewModel)
    case amount(AmountViewModel)
    case input(String)
}

extension ParameterViewModel {
    
    var inputTitle: String? {
        
        guard case let .input(title) = self else {
            return nil
        }
        
        return title
    }
}

extension Operation.Parameter {

    var inputTitle: String? {
        
        guard case let .input(input) = self else {
            return nil
        }
        
        return input.title
    }
}

extension Array where Element == Operation.Parameter {
    
    var inputTitle: String? {
        
        first(where: { $0.id == .input })?.inputTitle
    }
}
