//
//  AnywayPaymentElementViewFactory+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import SwiftUI

extension AnywayPaymentElementViewFactory 
where IconView == Text {
    
    static var preview: Self {
        
        return .init(
            makeIconView: { Text(String(describing: $0)) },
            widget: .preview
        )
    }
}
