//
//  AnywayPaymentParameterView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import RxViewModel
import SwiftUI

struct AnywayPaymentParameterView: View {
    
    let parameter: Parameter
    let event: (String) -> Void
    
    var body: some View {
        
        switch parameter.type {
        case .hidden:
            EmptyView()
            
        case .nonEditable:
#warning("replace with real components")
            Text("TBD: nonEditable parameter view")
            
        case let .select(option, options):
            if let selector = try? Selector(option: option, options: options) {
                
#warning("replace with factory")
                let reducer = SelectorReducer<Option>()
                let viewModel = SelectorViewModel(
                    initialState: selector,
                    reduce: reducer.reduce(_:_:),
                    handleEffect: { _,_ in }
                )
                
                let observing = RxObservingViewModel(
                    observable: viewModel,
                    observe: { event($0.selected.key.rawValue) }
                )
                
                SelectorWrapperView(
                    viewModel: observing,
                    idKeyPath: \.key,
                    factory: .init(
                        createOptionView: { Text($0.value.rawValue) },
                        createSelectedOptionView: { Text($0.value.rawValue) }
                    )
                )
            }
            
        case .textInput:
#warning("replace with real components")
            Text("TBD: textInput")
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Option = AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option
}

// MARK: - Adapters

private extension Selector where T == AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option {
    
    init(option: Option, options: [Option]) throws {
        
        try self.init(
            selected: option, 
            options: options,
            filterPredicate: { $0.contains($1) }
        )
    }
    
    typealias Option = AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option
}
    
private extension AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option {
    
    func contains(_ string: String) -> Bool {
        
        key.rawValue.contains(string) || value.rawValue.contains(string)
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayPayment.Element.UIComponent.Parameter
}

#Preview {
    
    ScrollView(showsIndicators: false) {
        
        VStack(spacing: 32) {
            
            AnywayPaymentParameterView(parameter: .textInput, event: { print($0) })
            AnywayPaymentParameterView(parameter: .select, event: { print($0) })
        }
    }
}

private extension AnywayPayment.Element.UIComponent.Parameter {
    
    static let textInput: Self = .init(id: .init(UUID().uuidString), type: .textInput, value: nil)
    
    static let select: Self = .init(
        id: .init(UUID().uuidString),
        type: .select(
            .init(key: "a", value: "Option A"),
            [.init(key: "a", value: "Option A"),
             .init(key: "b", value: "Option B"),
             .init(key: "c", value: "Option C")]
        ),
        value: nil
    )
}
