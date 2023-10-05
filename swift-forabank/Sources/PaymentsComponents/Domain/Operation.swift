//
//  Operation.swift
//  
//
//  Created by Дмитрий Савушкин on 03.10.2023.
//

import Foundation

public struct Operation {
    
    public let parameters: [Parameter]
    
    public enum Parameter {
        
        case input(ParameterInput)
        case hint(ParameterHint)
        case selector(ParameterSelect)
        case sticker(ParameterSticker)
        case product(ParameterProduct)
    }
}
