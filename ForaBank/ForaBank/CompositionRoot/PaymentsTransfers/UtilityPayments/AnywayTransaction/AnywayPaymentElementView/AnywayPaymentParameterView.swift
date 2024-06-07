//
//  AnywayPaymentParameterView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
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
            
        case .numberInput:
#warning("replace with specific number input view")
            factory.makeTextInputView(parameter, { event($0.dynamic.value) })
            
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
    
    typealias Parameter = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter
    typealias Factory = AnywayPaymentParameterViewFactory
}

extension InputConfig {
    
    static var iFora: Self { .preview }
}

// MARK: - Adapters

private extension Selector where T == AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    init(option: Option, options: [Option]) throws {
        
        try self.init(
            selected: option,
            options: options,
            filterPredicate: { $0.contains($1) }
        )
    }
    
    typealias Option = AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option
}

private extension AnywayPaymentDomain.AnywayElement.UIComponent.Parameter.ParameterType.Option {
    
    func contains(_ string: String) -> Bool {
        
        key.rawValue.contains(string) || value.rawValue.contains(string)
    }
}
