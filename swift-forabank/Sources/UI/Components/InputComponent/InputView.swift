//
//  InputView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI
import SharedConfigs

public struct InputView<Icon, IconView: View>: View {

    let state: InputState<Icon>
    let event: (InputEvent) -> Void
    let config: InputConfig
    let iconView: () -> IconView
    
    public init(
        state: InputState<Icon>,
        event: @escaping (InputEvent) -> Void,
        config: InputConfig,
        iconView: @escaping () -> IconView
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                iconView()
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    state.settings.title.text(withConfig: config.titleConfig)
                    
                    
                    TextField(
                        config.placeholder,
                        text: .init(
                            get: { state.dynamic.value },
                            set: { event(.edit($0)) }
                        )
                    )
                }
            }
            
            if let hint = state.settings.hint {
                
                HStack(alignment: .center, spacing: 16) {
                    
                    Color.clear
                        .frame(width: config.imageSize.rawValue, height: config.imageSize.rawValue, alignment: .leading)
                    
                    Text(hint)
                        .font(config.hintConfig.textFont)
                        .foregroundColor(config.hintConfig.textColor)
                }
            }
        }
        .padding(.horizontal, config.imageSize == .small ? 16 : 12)
        .padding(.vertical, 13)
        .background(config.backgroundColor)
        .cornerRadius(12)
    }
}

public extension InputConfig {
    
    static let preview: Self = .init(
        titleConfig: .init(textFont: .title3, textColor: .gray),
        textFieldFont: .init(textFont: .title3, textColor: .gray),
        placeholder: "Введите лицевой счет",
        hintConfig: .init(textFont: .body, textColor: .gray),
        backgroundColor: .gray.opacity(0.1),
        imageSize: .small
    )
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InputView(
                state: .preview,
                event: { _ in },
                config: .preview,
                iconView: { Text("Icon view") }
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
        subtitle: "input subtitle"
    )
}
