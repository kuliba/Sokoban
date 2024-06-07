//
//  AnywayPaymentElementParameterView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 14.04.2024.
//

import AnywayPaymentDomain
import SwiftUI
import Tagged

struct AnywayPaymentElementParameterView: View {
    
    let state: AnywayElement.UIComponent.Parameter
    let event: (String) -> Void
    
    var body: some View {
        
        switch state.type {
        case .hidden:
            EmptyView()
            
        case .nonEditable:
            Text("TBD: non editable parameter")
            
        case let .select(selected, options):
            ExpandablePickerStateWrapperView(
                viewModel: .decorated(
                    initialState: .init(items: options),
                    onSelect: { event($0.key.rawValue) }
                ),
                itemView: { Text($0.value.rawValue) }
            )
            
        case .numberInput:
            TextFieldMockWrapperView(
                initial: state.value?.rawValue ?? "",
                onChange: event
            )
            
        case .textInput:
            TextFieldMockWrapperView(
                initial: state.value?.rawValue ?? "",
                onChange: event
            )
            
        case .unknown:
            EmptyView()
        }
    }
}

extension AnywayElement.UIComponent.Parameter.ParameterType.Option: Identifiable {
    
    public var id: Key { key }
}

struct AnywayPaymentElementParameterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32, content: previewsGroup)
            .padding(.horizontal)
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            anywayPaymentElementParameterView(.select)
            anywayPaymentElementParameterView(.emptyTextInput)
            anywayPaymentElementParameterView(.textInput)
        }
    }
    
    static func anywayPaymentElementParameterView(
        _ parameter: AnywayElement.Parameter
    ) -> some View {
        
        AnywayPaymentElementParameterView(state: parameter.uiComponent, event: { _ in })
    }
}
