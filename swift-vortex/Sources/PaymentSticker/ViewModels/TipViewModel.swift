//
//  TipViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct TipViewModel {
    
    let text: String
    
    public init(text: String) {
        self.text = text
    }
}

//MARK: Helpers

extension TipViewModel {
    
    public init(parameter: Operation.Parameter.Tip) {
        self.text = parameter.title
    }
}
