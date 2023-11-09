//
//  InputViewModel.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import Foundation

public struct InputViewModel {
    
    public typealias Parameter = Operation.Parameter.Input

    public let parameter: Parameter
    let updateValue: (String) -> Void
    
    public init(
        parameter: InputViewModel.Parameter,
        updateValue: @escaping (String) -> Void
    ) {
        self.parameter = parameter
        self.updateValue = updateValue
    }
}
