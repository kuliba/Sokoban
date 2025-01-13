//
//  ValueMagicView.swift
//  
//
//  Created by Igor Malyarov on 23.11.2023.
//

import SwiftUI

/// A view that presents when value become non-nil.
public struct ValueMagicView<Value, ValueView>: View
where ValueView: View {
    
    public typealias GetValue = (@escaping (Value?) -> Void) -> Void
    
    private let getValue: GetValue
    private let valueView: (Value) -> ValueView
    
    @State private var value: Value?
    
    public init(
        initialValue value: Value? = nil,
        getValue: @escaping GetValue,
        valueView: @escaping (Value) -> ValueView
    ) {
        self._value = .init(initialValue: value)
        self.getValue = getValue
        self.valueView = valueView
    }
    
    public var body: some View {
        
        ZStack {
            
            value.map(valueView)
            
            Color.clear
                .frame(width: 0, height: 0)
                .onAppear { getValue { value = $0 }}
        }
    }
}

struct ValueMagicView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            ValueMagicView(
                getValue: { $0("some value") },
                valueView: { Text($0) }
            )
            
            ValueMagicView(
                getValue: { $0(nil) },
                valueView: { (text: String) in Text(text) }
            )
            
            ValueMagicView(
                getValue: { completion in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        completion("delayed value")
                    }
                },
                valueView: { Text($0) }
            )
        }
    }
}
