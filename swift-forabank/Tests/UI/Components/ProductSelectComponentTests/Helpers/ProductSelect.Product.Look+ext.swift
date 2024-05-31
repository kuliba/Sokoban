//
//  Helpers.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import ProductSelectComponent
import SwiftUI

extension ProductSelect.Product.Look {
    
    static func test(color: Color = .red) -> Self {
        
        .init(
            background: .svg(""),
            color: color,
            icon: .svg("")
        )
    }
}
