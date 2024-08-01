//
//  InputPhoneView.swift
//
//
//  Created by Дмитрий Савушкин on 05.03.2024.
//

import SwiftUI
import TextFieldComponent
import SearchBarComponent

public struct InputPhoneView: View {
    
    let state: InputPhoneState
    let event: (InputPhoneEvent) -> Void
    let config: InputPhoneConfig
    
    public init(
        state: InputPhoneState,
        event: @escaping (InputPhoneEvent) -> Void,
        config: InputPhoneConfig
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        HStack(spacing: 12) {
            
            config.icon
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(config.iconForeground)
            
            switch state {
            case .placeholder:
                config.placeholder.text(withConfig: config.placeholderConfig)
                
            case let .entered(text):
                VStack(alignment: .leading, spacing: 0) {
                    
                    config.title.text(withConfig: config.titleConfig)
                        .multilineTextAlignment(.leading)
                    
                    TextFieldComponent.TextFieldView(
                        viewModel: TextFieldFactory.makePhoneKitTextField(
                            initialPhoneNumber: text,
                            placeholderText:
                                config.placeholder,
                            filterSymbols: [],
                            countryCodeReplaces: [],
                            limit: 10,
                            needCloseButton: false
                        ),
                        keyboardType: .number,
                        toolbar: .none,
                        textFieldConfig: config.textFieldConfig
                    )
                }
            }
            
            Spacer()
            
            Button(
                action: { },
                label: {
                    
                    config.buttonIcon
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                        .foregroundColor(config.buttonForeground)
                })
            
        }
        .frame(height: 72)
        .padding(.leading, 16)
        .padding(.trailing, 13)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

public extension InputPhoneConfig {
    
    static let preview: Self = .init(
        icon: .init(systemName: "iphone"),
        iconForeground: .gray.opacity(0.7),
        placeholder: "Введите номер телефона",
        placeholderConfig: .init(textFont: .body, textColor: .gray.opacity(0.7)),
        title: "Номер телефона",
        titleConfig: .init(textFont: .system(size: 14), textColor: .gray.opacity(0.7)),
        buttonIcon: .init(systemName: "person"),
        buttonForeground: .gray.opacity(0.7),
        textFieldConfig: .preview
    )
}

struct InputPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InputPhoneView(
                state: .placeholder,
                event: { _ in },
                config: .preview
            )
            
            InputPhoneView(
                state: .entered("7 982"),
                event: { _ in },
                config: .preview
            )
        }
        .padding(20)
    }
}
