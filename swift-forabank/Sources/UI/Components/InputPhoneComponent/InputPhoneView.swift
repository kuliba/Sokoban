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
                Text(config.placeholder)
                    .foregroundColor(config.placeholderForeground)
                
            case .entered:
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(config.title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleForeground)
                        .multilineTextAlignment(.leading)
                    
                    TextFieldComponent.TextFieldView(
                        viewModel: TextFieldFactory.makePhoneKitTextField(
                            initialPhoneNumber: "7 982",
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

public extension InputPhoneView {
    
    struct InputPhoneConfig {
        
        let icon: Image
        let iconForeground: Color
        
        let placeholder: String
        let placeholderForeground: Color
        
        let title: String
        let titleFont: Font
        let titleForeground: Color
        
        let buttonIcon: Image
        let buttonForeground: Color
        
        let textFieldConfig: TextFieldView.TextFieldConfig
        
        public init(
            icon: Image,
            iconForeground: Color,
            placeholder: String,
            placeholderForeground: Color,
            title: String,
            titleFont: Font,
            titleForeground: Color,
            buttonIcon: Image,
            buttonForeground: Color,
            textFieldConfig: TextFieldView.TextFieldConfig
        ) {
            self.icon = icon
            self.iconForeground = iconForeground
            self.placeholder = placeholder
            self.placeholderForeground = placeholderForeground
            self.title = title
            self.titleFont = titleFont
            self.titleForeground = titleForeground
            self.buttonIcon = buttonIcon
            self.buttonForeground = buttonForeground
            self.textFieldConfig = textFieldConfig
        }
    }
}
public extension InputPhoneView.InputPhoneConfig {
    
    static let preview: Self = .init(
        icon: .init(systemName: "iphone"),
        iconForeground: .gray.opacity(0.7),
        placeholder: "Введите номер телефона",
        placeholderForeground: .gray.opacity(0.7),
        title: "Номер телефона",
        titleFont: .system(size: 14),
        titleForeground: .gray.opacity(0.7),
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
                state: .entered,
                event: { _ in },
                config: .preview
            )
        }
        .padding(20)
    }
}
