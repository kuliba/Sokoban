//
//  Helpers.swift
//
//
//  Created by Igor Malyarov on 06.12.2023.
//

import Foundation
import PaymentComponents

extension ProductSelect.Product.Look {
    
    static func test(color: String = "red") -> Self {
        
        .init(
            background: .svg(""),
            color: color,
            icon: .svg("")
        )
    }
}
