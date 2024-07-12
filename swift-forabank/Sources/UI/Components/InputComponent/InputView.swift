//
//  InputView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI
import SharedConfigs
import TextFieldComponent

public struct InputView<Icon, IconView: View>: View {
    
    @StateObject private var regularFieldViewModel: RegularFieldViewModel
    
    let state: InputState<Icon>
    let event: (InputEvent) -> Void
    let config: InputConfig
    let commit: (String) -> Void
    let iconView: () -> IconView
    let isValid: (String) -> Bool
    
    public init(
        state: InputState<Icon>,
        event: @escaping (InputEvent) -> Void,
        config: InputConfig,
        iconView: @escaping () -> IconView,
        commit: @escaping (String) -> Void,
        isValid: @escaping (String) -> Bool
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.iconView = iconView
        self.commit = commit
        self.isValid = isValid
        
        let regularFieldViewModel: RegularFieldViewModel = .make(
            keyboardType: .init(keyboardType: config.keyboardType),
            text: state.dynamic.value,
            placeholderText: config.placeholder,
            limit: config.limit,
            regExp: config.regExp
        )
        
        self._regularFieldViewModel = .init(
            wrappedValue: regularFieldViewModel
        )
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                iconView()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    state.settings.title.text(withConfig: config.titleConfig)
                    
                    TextFieldView(
                        viewModel: regularFieldViewModel,
                        textFieldConfig: .init(
                            font: .systemFont(ofSize: 16),
                            textColor: config.textFieldFont.textColor,
                            tintColor: .black,
                            backgroundColor: .clear,
                            placeholderColor: .gray.opacity(0.3)
                        )
                    )
                    .onChange(of: regularFieldViewModel.text ?? "", perform: commit)
                    
                }
            }
            
            if let hint = state.settings.hint, !isValid(state.dynamic.value) {
                
                HStack(alignment: .center, spacing: 16) {
                    
                    Color.clear
                        .frame(width: config.imageSize, height: config.imageSize, alignment: .leading)
                    
                    Text(hint)
                        .font(config.hintConfig.textFont)
                        .foregroundColor(config.hintConfig.textColor)
                }
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
        }
        .transition(.opacity)
        .animation(.bouncy)
        .onTapGesture {
            
            regularFieldViewModel.send(.startEditing)
        }
    }
}

private extension KeyboardType {
    
    init(keyboardType: InputConfig.KeyboardType) {
        
        switch keyboardType {
        case .decimal:
            self = .decimal
        case .default:
            self = .default
        case .number:
            self = .number
        }
    }
}

public extension InputConfig {
    
    static let preview: Self = .init(
        titleConfig: .init(
            textFont: .subheadline,
            textColor: .gray
        ),
        textFieldFont: .init(
            textFont: .subheadline,
            textColor: .gray
        ),
        placeholder: "Введите лицевой счет",
        hintConfig: .init(textFont: .body, textColor: .red),
        backgroundColor: .gray.opacity(0.1),
        imageSize: 16,
        keyboardType: .decimal,
        limit: 4,
        regExp: ""
    )
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InputView(
                state: .preview,
                event: { _ in },
                config: .preview,
                iconView: { Text("Icon view") },
                commit: { _ in },
                isValid: { _ in true }
            )
        }
        .padding(20)
    }
}

extension InputState where Icon == String {
    
    static var preview: Self = .init(
        dynamic: .preview,
        settings: .preview
    )
}

private extension InputState.Dynamic where Icon == String {
    
    static var preview: Self = .init(
        value: "some value",
        warning: nil
    )
}

private extension InputState.Settings where Icon == String {
    
    static var preview: Self = .init(
        hint: "hint here",
        icon: "inputIcon",
        keyboard: .default,
        title: "input title",
        subtitle: "input subtitle",
        regExp: "",
        limit: 1
    )
}
