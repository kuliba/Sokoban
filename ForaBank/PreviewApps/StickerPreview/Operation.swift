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
    }
}
