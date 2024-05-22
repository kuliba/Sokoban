//
//  AnywayPaymentFieldView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentFieldView: View {
    
    let field: AnywayPayment.Element.UIComponent.Field
    
    var body: some View {
        
        #warning("replace with real components")
        Text("field view for \(field)")
    }
}

#Preview {
    AnywayPaymentFieldView(field: .preview)
}

private extension AnywayPayment.Element.UIComponent.Field {
    
    static let preview: Self = .init(name: "field name", title: "field title", value: "field value")
}
