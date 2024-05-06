//
//  NameView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI
import InputComponent
import SharedConfigs

public struct NameView<Icon, IconView: View>: View {
    
    private let state: NameViewState
    @State private(set) var text: String = ""
    private let event: (NameEvent) -> Void
    private let iconView: () -> IconView
    private let config: InputConfig
    
    public init(
        state: NameViewState,
        text: String,
        event: @escaping (NameEvent) -> Void,
        config: InputConfig,
        iconView: @escaping () -> IconView
    ) {
        self.state = state
        self.text = text
        self.event = event
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        switch state.state {
        case .collapse:
            
            fieldView(
                FieldTitle.general.rawValue,
                FieldPlaceholder.general.rawValue,
                collapseButton: true
            )
            .background(config.backgroundColor)
            .cornerRadius(12)
            
        case .expended:
            
            VStack {
                
                fieldView(
                    FieldTitle.surname.rawValue,
                    FieldPlaceholder.surname.rawValue,
                    collapseButton: true
                )
                
                fieldView(
                    FieldTitle.name.rawValue,
                    FieldPlaceholder.name.rawValue,
                    collapseButton: false
                )
                
                fieldView(
                    FieldTitle.patronymic.rawValue,
                    FieldPlaceholder.patronymic.rawValue,
                    collapseButton: false
                )
            }
            .background(config.backgroundColor)
            .cornerRadius(12)
        }
    }
    
    private func fieldView(
        _ title: String,
        _ placeholder: String,
        collapseButton: Bool
    ) -> some View {
        
        HStack {
            
            InputView(
                state: .init(
                    dynamic: .init(value: text.description),
                    settings: .init(
                        icon: Image.init(systemName: ""),
                        keyboard: .default,
                        title: title,
                        subtitle: nil
                    )),
                event: {_ in },
                config: config,
                iconView: iconView
            )
            
            if collapseButton {
                
                Button(
                    action: { },
                    label: {
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.gray.opacity(0.7))
                    })
            }
        }
        .padding(.trailing, 16)
    }
}

private extension NameView {
    
    enum FieldTitle: String {
        
        case name = "Имя получателя*"
        case surname = "Фамилия получателя*"
        case patronymic = "Отчество получателя (если есть)"
        case general = "ФИО Получателя"
    }
    
    enum FieldPlaceholder: String {
        
        case name = "Введите Имя Получателя"
        case surname = "Введите Фамилию Получателя"
        case patronymic = "Введите Отчество Получателя"
        case general = "Введите ФИО Получателя"
    }
}

private extension InputConfig {
    
    static let preview: Self = .init(
        titleConfig: .init(textFont: .system(size: 12), textColor: .gray.opacity(0.8)),
        textFieldFont: .init(textFont: .system(size: 14), textColor: .black),
        placeholder: "placeholder",
        hintConfig: .init(textFont: .system(size: 10), textColor: .gray.opacity(0.7)),
        backgroundColor: .clear,
        imageSize: 16
    )
}

struct NameView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 20) {
                
                NameView<Any, EmptyView>(
                    state: .init(state: .collapse),
                    text: "",
                    event: { state in },
                    config: .preview,
                    iconView: { return EmptyView() }
                )
                
                NameView<Any, EmptyView>(
                    state: .init(state: .expended),
                    text: "",
                    event: { state in },
                    config: .preview,
                    iconView: { return EmptyView() }
                )
            }
        }
        .padding(.horizontal, 20)
    }
}
