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
            selector.map(selectorView)
            
        case .textInput:
            textInputView(parameter)
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayPaymentParameterView {
    
    typealias Parameter = AnywayPayment.Element.UIComponent.Parameter
    typealias Factory = AnywayPaymentParameterViewFactory
}

private extension AnywayPaymentParameterView {
    
    private func selectorView(
        selector: Selector<Option>
    ) -> some View {
        
#warning("extract to factory")
        let reducer = SelectorReducer<Option>()
        let viewModel = RxViewModel(
            initialState: selector,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        let observing = RxObservingViewModel(
            observable: viewModel,
            observe: { event($0.selected.key.rawValue) }
        )
        
        return SelectorWrapperView(
            viewModel: observing,
            factory: .init(
                createOptionView: { OptionView(option: $0) },
                createSelectedOptionView: { SelectedOptionView(option: $0) }
            )
        )
    }
    
    typealias Option = AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option
}

private extension AnywayPaymentParameterView {
    
    @ViewBuilder
    func textInputView(
    _ parameter: Parameter
    ) -> some View {
        
        switch parameter.type {
            
        case .textInput:
#warning("extract to factory")
            let inputState = InputState(parameter)
            let reducer = InputReducer<String>()
            let viewModel = RxViewModel(
                initialState: inputState,
                reduce: reducer.reduce(_:_:),
                handleEffect: { _,_ in }
            )
            
            let observing = RxObservingViewModel(
                observable: viewModel,
                observe: { event($0.dynamic.value) }
            )
            
            InputStateWrapperView(
                viewModel: observing,
                factory: .init(
                    makeInputView: {
                        
                        InputView(state: $0, event: $1, config: .iFora, iconView: { Text("?") })
                    }
                )
            )
            
        default:
            EmptyView()
        }
    }
}

private extension InputConfig {
    
    static var iFora: Self { .preview }
}

// MARK: - Adapters

private extension InputState where Icon == String {
    
    #warning("FIXME: replace stubbed with values from parameter")
    init(_ parameter: AnywayPayment.Element.UIComponent.Parameter) {
        
        self.init(
            dynamic: .init(
                value: parameter.value?.rawValue ?? "",
                warning: nil
            ),
            settings: .init(
                hint: nil,
                icon: "",
                keyboard: .default,
                title: parameter.title,
                subtitle: parameter.subtitle
            )
        )
    }
}

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

// MARK: - Previews

#Preview {
    
    ScrollView(showsIndicators: false) {
        
        VStack(spacing: 32) {
            
            AnywayPaymentParameterView(parameter: .textInput, event: { print($0) }, factory: .preview)
            AnywayPaymentParameterView(parameter: .select, event: { print($0) }, factory: .preview)
        }
    }
}

private extension AnywayPayment.Element.UIComponent.Parameter {
    
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
