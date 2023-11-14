//
//  ContentView.swift
//  PhoneNumberTextViewPreview
//
//  Created by Igor Malyarov on 26.04.2023.
//

import SearchBarComponent
import SwiftUI
import TextFieldComponent

typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>
  
struct ContentView: View {
    
    @StateObject private var viewModel: ViewModel = .init(
        initialState: .placeholder("Enter phone number"),
        reducer: TransformingReducer(placeholderText: "Enter phone number"),
        keyboardType: .decimal
    )
    @StateObject private var textFieldViewModel = TextFieldFactory.makePhoneTextFieldModel(
        placeholderText: "Enter phone number",
        substitutions: .preview,
        format: {
            guard !$0.isEmpty else { return "" }
            
            return "+\($0)"
        },
        limit: 6
    )
    
    @State private var isShowingAlert = false
    
    private let buttonsColor: Color = .purple
    
    var body: some View {
        
        NavigationView {
            
            let textFieldConfig: TextFieldView.TextFieldConfig = .init(
                font: .systemFont(ofSize: 19, weight: .regular),
                textColor: .orange,
                tintColor: .black,
                backgroundColor: .clear,
                placeholderColor: .gray
            )
            
            VStack {
                
                Group {
                    TextFieldView.init(
                        viewModel: textFieldViewModel,
                        textFieldConfig: textFieldConfig
                    )
                    
                    CancellableSearchBarView(
                        viewModel: viewModel,
                        textFieldConfig: textFieldConfig,
                        clearButtonLabel: clearButtonLabel,
                        cancelButton: cancelButton
                    )
                    
                    CancellableSearchBarView(
                        viewModel: viewModel,
                        textFieldConfig: textFieldConfig,
                        clearButtonLabel: clearButtonLabel,
                        cancelButton: EmptyView.init
                    )
                    
                    DefaultCancellableSearchBarView(
                        viewModel: viewModel,
                        textFieldConfig: textFieldConfig,
                        buttonsColor: buttonsColor,
                        cancel: { isShowingAlert = true }
                    )
                }
                .wrappedInRoundedRectangle(strokeColor: .orange)
                .animation(.easeInOut, value: viewModel.state)
                .padding()
                
                Form {
                    Section {
                        TextFieldView(
                            viewModel: ReducerTextFieldViewModel(
                                initialState: .placeholder("Enter phone number"),
                                reducer: TransformingReducer(placeholderText: "Enter phone number"),
                                keyboardType: .decimal
                            ),
                            textFieldConfig: textFieldConfig
                        )
                    } header: {
                        Text("Phone number input")
                    } footer: {
                        Text(footerText)
                    }
                }
            }
            .navigationTitle("Text input options demo")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Cancel", isPresented: $isShowingAlert) {
            } message: {
                Text("Cancel action was invoked.")
            }
        }
    }
    
    private func clearButtonLabel() -> some View {
        
        Image(systemName: "xmark")
            .resizable()
            .imageScale(.small)
            .frame(width: 12, height: 12)
            .foregroundColor(buttonsColor)
    }
    
    private func cancelButton() -> some View {
        
        Button(action: cancel) {
            Text("cancel")
                .foregroundColor(buttonsColor)
                .font(.system(size: 14))
        }
    }
    
    private func cancel() {
        
        isShowingAlert = true
    }
    
    private let footerText: String = """
- works with substitutions:
\t- "3" to "+374",
\t- "8" to "+7",
\t- "9" to "+7 9"
- all symbols could be deleted
"""
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DefaultCancellableSearchBarView: View {
    
    @ObservedObject private var viewModel: ViewModel
    private let textFieldConfig: TextFieldView.TextFieldConfig
    private let buttonsColor: Color
    private let cancel: () -> Void
    
    init(
        viewModel: ViewModel,
        textFieldConfig: TextFieldView.TextFieldConfig,
        buttonsColor: Color,
        cancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.textFieldConfig = textFieldConfig
        self.buttonsColor = buttonsColor
        self.cancel = cancel
    }
    
    var body: some View {
        
        CancellableSearchBarView(
            viewModel: viewModel,
            textFieldConfig: textFieldConfig,
            clearButtonLabel: clearButtonLabel,
            cancelButton: cancelButton
        )
    }
    
    private func clearButtonLabel() -> some View {
        
        Image(systemName: "xmark")
            .resizable()
            .imageScale(.small)
            .frame(width: 12, height: 12)
            .foregroundColor(buttonsColor)
    }
    
    private func cancelButton() -> some View {
        
        Button(action: cancel) {
            Text("cancel")
                .foregroundColor(buttonsColor)
                .font(.system(size: 14))
        }
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

enum TextFieldFactory {}

extension TextFieldFactory {
    
    static func makePhoneTextFieldModel(
        placeholderText: String,
        filterSymbols: [Character] = [],
        substitutions: [CountryCodeSubstitution],
        format: @escaping (String) -> String,
        limit: Int? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ViewModel {
        
        let transformer = Transformers.phone(
            filterSymbols: filterSymbols,
            substitutions: substitutions,
            format: format,
            limit: limit
        )
        let reducer = TransformingReducer(
            placeholderText: placeholderText,
            transformer: transformer
        )
        let toolbar = ToolbarFactory.makeToolbarViewModel(
            closeButtonLabel: .image("Close Button"),
            closeButtonAction: {},
            doneButtonLabel: .title("Готово"),
            doneButtonAction: {}
        )
        
        return .init(
            initialState: .placeholder(placeholderText),
            reducer: reducer,
            keyboardType: .number,
            toolbar: toolbar,
            scheduler: scheduler
        )
    }
}

extension Array where Element == CountryCodeSubstitution {
    
    static let preview: Self = .russian
    
    static let russian: Self = [
        .init(from: "89", to: "79"),
    ]
}
