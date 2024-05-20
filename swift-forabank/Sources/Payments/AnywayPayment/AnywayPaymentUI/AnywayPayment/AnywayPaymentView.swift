//
//  AnywayPaymentView.swift
//
//
//  Created by Igor Malyarov on 21.04.2024.
//

import SwiftUI

struct AnywayPaymentView<Icon, InfoView, InputView, ProductPicker>: View
where InfoView: View,
      InputView: View,
      ProductPicker: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        VStack {
            
            factory.makeInfoView(state.info)
            factory.makeInputView(state.input, { event(.input($0)) })
            factory.makeProductPicker(state.product, { event(.select($0)) })
        }
    }
}

extension AnywayPaymentView {
    
    typealias State = AnywayPaymentState<Icon>
    typealias Event = AnywayPaymentEvent
    
    typealias Factory = AnywayPaymentComponentFactory<Icon, InfoView, InputView, ProductPicker>
}

// MARK: - Previews

struct AnywayPaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AnywayPaymentView(
            state: .preview,
            event: { _ in },
            factory: .preview
        )
    }
}

extension AnywayPaymentState where Icon == String {
    
    static var preview: Self {
        
        .init(info: .preview, input: .preview, product: .preview)
    }
}

extension Product {
    
    static let preview: Self = .init()
}

extension AnywayPaymentComponentFactory
where InfoView == Text,
      InputView == Text,
      ProductPicker == Text {
    
    static var preview: Self {
        
        .init(
            makeInfoView: { _ in Text("InfoView") },
            makeInputView: { _,_ in Text("InputView") },
            makeProductPicker: { _,_ in Text("ProductPicker") }
        )
    }
}
