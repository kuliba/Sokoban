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
    
    @ObservedObject var inputViewModel: RxInputViewModel
    
    let config: TextInputConfig
    
    var body: some View {
        
        VStack {
            
            TextInputView(
                state: inputViewModel.state,
                event: inputViewModel.event,
                config: config,
                iconView: EmptyView.init
            )
            .padding()
            .background(.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .keyboardType(.numberPad)
            
            Text(String(describing: inputViewModel.state.uinInputState))
                .font(.headline)
            
            Spacer()
            
            continueButton()
            sbpIcon()
        }
    }
    
    @ViewBuilder
    private func continueButton() -> some View {
        
        Button(action: { print("continue: \(inputViewModel.state.uinInputState.value)") }) {
            
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .disabled(!inputViewModel.state.uinInputState.isValid || inputViewModel.state.uinInputState.isEditing)
    }
    
    private func sbpIcon() -> some View {
        
        Image(systemName: "envelope")
            .imageScale(.large)
    }
}

private struct UINInputState: Equatable {
    
    var isEditing = false
    var isValid = false
    var value = ""
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
            isValid: message == nil && !textField.text.isNilOrEmpty,
            value: textField.text ?? ""
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
