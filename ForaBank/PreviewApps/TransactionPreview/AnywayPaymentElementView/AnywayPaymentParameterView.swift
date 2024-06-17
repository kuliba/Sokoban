//
//  AnywayPaymentParameterView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI

struct AnywayPaymentParameterView: View {
    
    let parameter: Parameter
    let event: (String) -> Void
    let factory: Factory
    
    var body: some View {
        
        switch parameter.type {
        case .hidden:
            EmptyView()
            
        case .nonEditable:
#warning("replace with real components")
            Text("TBD: nonEditable parameter view")
            
        case let .select(option, options):
            let selector = try? Selector(option: option, options: options)
            selector.map {
             
                factory.makeSelectorView($0, { event($0.selected.key.rawValue) })
            }
            
        case .textInput:
            factory.makeTextInputView(parameter, { event($0.dynamic.value) })
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayElement.UIComponent.Parameter
    typealias Factory = AnywayPaymentParameterViewFactory
}

extension InputConfig {
    
    static var iFora: Self { .preview }
}

// MARK: - Adapters

private extension Selector where T == AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    init(option: Option, options: [Option]) throws {
        
        try self.init(
            selected: option,
            options: options,
            filterPredicate: { $0.contains($1) }
        )
    }
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}

private extension AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    func contains(_ string: String) -> Bool {
        
        key.rawValue.contains(string) || value.rawValue.contains(string)
    }
}

// MARK: - Previews

#Preview {
    
    ScrollView(showsIndicators: false) {
        
        VStack(spacing: 32) {
            
            AnywayPaymentParameterView(parameter: .textInput, event: { print($0) }, factory: .preview)
            AnywayPaymentParameterView(parameter: .select, event: { print($0) }, factory: .preview)
        }
    }
}

private extension AnywayElement.UIComponent.Parameter {
    
    static let textInput: Self = .init(
        id: .init(UUID().uuidString),
        type: .textInput, 
        title: "Text Input",
        subtitle: "Field for text input",
        value: nil
    )
    
    static let select: Self = .init(
        id: .init(UUID().uuidString),
        type: .select(
            .init(key: "a", value: "Option A"),
            [.init(key: "a", value: "Option A"),
             .init(key: "b", value: "Option B"),
             .init(key: "c", value: "Option C")]
        ),
        title: "Select",
        subtitle: "select option",
        value: nil
    )
}
