//
//  ContentView.swift
//  C2GPreviewApp
//
//  Created by Igor Malyarov on 12.02.2025.
//

import InputComponent
import RxViewModel
import SwiftUI
import TextFieldDomain

struct ContentView: View {
    
    @State private var uinInputState: UINInputState = .init()
    
    @ObservedObject var inputViewModel: RxInputViewModel
    
    let config: TextInputConfig
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                RxWrapperView(model: inputViewModel) { state, event in
                    
                    TextInputView(
                        state: state,
                        event: event,
                        config: config,
                        iconView: EmptyView.init
                    )
                    .onChange(of: state.uinInputState) { uinInputState = $0 }
                    .padding()
                    .background(.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                    .keyboardType(.numberPad)
                    
                    Text(String(describing: state.uinInputState))
                        .font(.headline)
                }
                
                Spacer()
                
                continueButton()
                sbpIcon()
            }
            
            settings
        }
    }
    
    @ViewBuilder
    private func continueButton() -> some View {
        
        if !uinInputState.isEditing {
            
            Button(action: {}) {
                
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(!uinInputState.isValid)
        }
    }
    
    private func sbpIcon() -> some View {
        
        Image(systemName: "envelope")
            .imageScale(.large)
    }
    
    private var settings: some View {
        
        VStack(spacing: 16) {
            
            Text("UIN Input State")
                .font(.headline)
            
            HStack {
                
                Text(uinInputState.isEditing ? "editing" : "noFocus")
                Divider()
                Text(uinInputState.isValid ? "valid" : "not valid")
                    .foregroundStyle(uinInputState.isValid ? .green : .red)
            }
            .fixedSize()
            
            HStack {
                
                Button("editing") { uinInputState.isEditing = true }
                Divider()
                Button("no focus") { uinInputState.isEditing = false }
            }
            .fixedSize()
            
            HStack {
                
                Button("valid") { uinInputState.isValid = true }
                    .foregroundStyle(.green)
                Divider()
                Button("invalid") { uinInputState.isValid = false }
                    .foregroundStyle(.red)
            }
            .fixedSize()
        }
        .padding()
    }
}

private struct UINInputState: Equatable {
    
    var isEditing: Bool = false
    var isValid: Bool = false
}

private extension TextFieldState {
    
    var isEditing: Bool {
        
        switch self {
        case .editing: return true
        default:       return false
        }
    }
}

private extension TextInputState {
    
    var uinInputState: UINInputState {
        
        return .init(
            isEditing: textField.isEditing,
            isValid: message == nil && !textField.text.isNilOrEmpty
        )
    }
}

#Preview {
    
    ContentView(inputViewModel: .makeUINInputViewModel(), config: .preview)
}

extension TextInputConfig {
    
    static let preview: Self = .init(
        hint: .init(textFont: .footnote, textColor: .secondary),
        imageWidth: 24,
        keyboard: .number,
        placeholder: "УИН",
        textField: .preview(),
        title: "",
        titleConfig: .init(textFont: .headline, textColor: .secondary),
        toolbar: .init(closeImage: "", doneTitle: "Done"),
        warning: .init(textFont: .body, textColor: .red)
    )
}
