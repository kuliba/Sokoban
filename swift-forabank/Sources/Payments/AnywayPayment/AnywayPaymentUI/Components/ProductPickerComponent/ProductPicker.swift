//
//  ProductPicker.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import SwiftUI

struct ProductPicker: View {
    
    let state: State
    let event: (Event) -> Void
    let config: ProductPickerConfig
    
    var body: some View {
        
        Text("Product picker here")
    }
}

extension ProductPicker {
    
    typealias State = ProductPickerState
    typealias Event = ProductPickerEvent
}
