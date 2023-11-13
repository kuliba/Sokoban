//
//  InputViewModel.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 24.10.2023.
//

import Foundation
import SwiftUI

public struct InputViewModel {
    
    public typealias Parameter = Operation.Parameter.Input
    
    public let parameter: Parameter
    public let icon: Image
    
    let updateValue: (String) -> Void
    
    public init(
        parameter: InputViewModel.Parameter,
        icon: Image,
        updateValue: @escaping (String) -> Void
    ) {
        self.parameter = parameter
        self.icon = icon
        self.updateValue = updateValue
    }
}
