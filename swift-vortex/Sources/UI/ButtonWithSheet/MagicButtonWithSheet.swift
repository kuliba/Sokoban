//
//  MagicButtonWithSheet.swift
//
//
//  Created by Igor Malyarov on 23.11.2023.
//

import SwiftUI

public struct MagicButtonWithSheet<ButtonLabel, Value, ValueView>: View
where ButtonLabel: View,
      ValueView: View {
    
    public typealias GetValue = (@escaping (Value?) -> Void) -> Void
    public typealias MakeButtonLabel = () -> ButtonLabel
    public typealias Dismiss = () -> Void
    public typealias MakeValueView = (Value, @escaping Dismiss) -> ValueView
    
    private let buttonLabel: MakeButtonLabel
    private let getValue: GetValue
    private let makeValueView: MakeValueView
    
    public init(
        buttonLabel: @escaping MakeButtonLabel,
        getValue: @escaping GetValue,
        makeValueView: @escaping MakeValueView
    ) {
        self.buttonLabel = buttonLabel
        self.getValue = getValue
        self.makeValueView = makeValueView
    }
    
    public var body: some View {
        
        ValueMagicView(getValue: getValue, valueView: valueView)
    }
    
    private func valueView(value: Value) -> some View {
        
        typealias Completion = (Result<Value, Error>) -> Void
        
        return ButtonWithSheet(
            label: buttonLabel,
            getSheetState: { (completion: Completion) in
                
                completion(.success(value))
            },
            makeSheetStateView: { result, dismiss in
                
                switch result {
                case .failure:
                    EmptyView()
                    
                case let .success(value):
                    makeValueView(value, dismiss)
                }
            }
        )
    }
}

struct MagicButtonWithSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MagicButtonWithSheet(
            buttonLabel: { Image(systemName: "plane")},
            getValue: { completion in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    completion("some text")
                }
            },
            makeValueView: { value, dismiss in
                
                VStack(spacing: 64) {
                    
                    Button("close", action: dismiss)
                    
                    Text(value).bold()
                }
            }
        )
    }
}
