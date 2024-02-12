//
//  CancellableSearchBarView.swift
//  
//
//  Created by Igor Malyarov on 10.05.2023.
//

import SwiftUI
import TextFieldComponent

public struct CancellableSearchBarView<ClearButtonLabel: View, CancelButton: View>: View {
    
    public typealias ViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>
    
    @ObservedObject private var viewModel: ViewModel
    
    private let textFieldConfig: TextFieldView.TextFieldConfig
    private let clearButtonLabel: () -> ClearButtonLabel
    private let cancelButton: () -> CancelButton
    
    public init(
        viewModel: ViewModel,
        textFieldConfig: TextFieldView.TextFieldConfig,
        clearButtonLabel: @escaping () -> ClearButtonLabel,
        cancelButton: @escaping () -> CancelButton
    ) {
        self.viewModel = viewModel
        self.textFieldConfig = textFieldConfig
        self.clearButtonLabel = clearButtonLabel
        self.cancelButton = cancelButton
    }
    
    public var body: some View {
        
        HStack {
            
            TextFieldView(
                viewModel: viewModel,
                textFieldConfig: textFieldConfig
            ).accessibilityIdentifier("CancellableSearchField")
            
            switch viewModel.state {
            case .editing(.empty),
                    .noFocus(""),
                    .placeholder:
                cancelButton()
                
            case .editing, .noFocus:
                twoButtons()
            }
        }
    }
    
    private func twoButtons() -> some View {
        
        HStack(spacing: 16) {
            
            clearButton()
            cancelButton()
        }
    }
    
    private func clearButton() -> some View {
        
        Button {
            viewModel.setText(to: "")
        } label: {
            clearButtonLabel()
        }
    }
}

// MARK: - Previews

struct CancellableSearchBarView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CancellableSearchBarViewDemo()
    }
    
    struct CancellableSearchBarViewDemo: View {
        
        @StateObject private var viewModel: CancellableSearchBarView.ViewModel = .init(
            initialState: .placeholder("Enter phone number"),
            reducer: TransformingReducer(
                placeholderText: "Enter phone number"
            ),
            keyboardType: .default
        )
        
        var body: some View {
            
            CancellableSearchBarView(
                viewModel: viewModel,
                textFieldConfig: .preview,
                clearButtonLabel: PreviewClearButton.init,
                cancelButton: PreviewCancelButton.init
            )
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.green, lineWidth: 1)
            )
            .padding()
        }
    }
}
