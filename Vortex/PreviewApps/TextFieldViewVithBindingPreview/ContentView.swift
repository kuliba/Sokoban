//
//  ContentView.swift
//  TextFieldViewVithBindingPreview
//
//  Created by Igor Malyarov on 31.05.2023.
//

import TextFieldComponent
import SwiftUI

struct ContentView: View {
    
    @State private var state: TextFieldState = .placeholder("This text field uses binding")
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                textField
                    .wrappedInRoundedRectangle(strokeColor: .orange)
                    .padding()
                
                Form {
                    Section {
                        textField
                    } footer: {
                        Text("This is \"Form\"")
                    }
                }
            }
        }
    }
    
    private var textField: some View {
        
        let reducer = TransformingReducer(
            placeholderText: "This text field uses binding",
            transform: { $0 }
        )
        
        let textFieldConfig: TextFieldView.TextFieldConfig = .init(
            font: .systemFont(ofSize: 19, weight: .regular),
            textColor: .orange,
            tintColor: .black,
            backgroundColor: .clear,
            placeholderColor: .gray
        )
        
        return TextFieldView(
            state: $state,
            keyboardType: .default,
            toolbar: nil,
            send: { action in
                
                try? self.state = reducer.reduce(state, with: action)
            },
            textFieldConfig: textFieldConfig
        )
        
    }
}

extension View {
    
    func wrappedInRoundedRectangle(strokeColor: Color) -> some View {
        
        self
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(.leading, 14)
            .padding(.trailing, 15)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(strokeColor, lineWidth: 1)
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
