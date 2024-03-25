//
//  NameView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI
import InputComponent

public struct NameView: View {
    
    let state: NameViewState
    @State private var text: String = ""
    let event: (NameEvent) -> Void
    let config: InputView.Config
    
    public init(
        state: NameViewState,
        text: String,
        event: @escaping (NameEvent) -> Void,
        config: InputView.Config
    ) {
        self.state = state
        self.text = text
        self.event = event
        self.config = config
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
                state: .init(image: { .init(systemName: "person") }), 
                text: text,
                event: { event in },
                config: setupConfig(title, placeholder)
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
    
    private func setupConfig(
        _ title: String,
        _ placeholder: String
    ) ->  InputView.Config {
        
        .init(
            title: title,
            titleFont: config.titleFont,
            titleColor: config.titleColor,
            textFieldFont: config.textFieldFont,
            placeholder: placeholder,
            hint: nil,
            hintFont: config.hintFont,
            hintColor: config.hintColor,
            backgroundColor: .clear,
            imageSize: .small
        )
    }
}

private extension InputView.Config {
    
    static let preview: Self = .init(
        title: "title",
        titleFont: .system(size: 12),
        titleColor: .gray.opacity(0.8),
        textFieldFont: .system(size: 14),
        placeholder: "placeholder",
        hint: nil,
        hintFont: .system(size: 10),
        hintColor: .gray.opacity(0.7),
        backgroundColor: .clear,
        imageSize: .small
    )
}

struct NameView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 20) {
                
                NameView(
                    state: .init(state: .collapse),
                    text: "",
                    event: { state in },
                    config: .preview
                )
                
                NameView(
                    state: .init(state: .expended),
                    text: "",
                    event: { state in },
                    config: .preview
                )
            }
        }
        .padding(.horizontal, 20)
    }
}
