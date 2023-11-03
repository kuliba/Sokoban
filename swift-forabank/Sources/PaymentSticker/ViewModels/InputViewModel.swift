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
    
    public init(
        parameter: InputViewModel.Parameter
    ) {
        self.parameter = parameter
    }
}
