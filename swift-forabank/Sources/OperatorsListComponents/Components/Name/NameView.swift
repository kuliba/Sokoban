//
//  NameView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI

struct NameView: View {
    
    let state: NameViewState
    @State private var text: String = ""
    let nameEvent: (NameEvent) -> Void
    let config: InputView.InputConfigView
    
    var body: some View {
        
        switch state.state {
        case .collapse:
            
            fieldView(
                title: FieldTitle.general.rawValue,
                placeholder: FieldPlaceholder.general.rawValue,
                collapseButton: true
            )
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
        case .expended:
            
            VStack {
                
                fieldView(
                    title: FieldTitle.surname.rawValue,
                    placeholder: FieldPlaceholder.surname.rawValue,
                    collapseButton: true
                )
                
                fieldView(
                    title: FieldTitle.name.rawValue,
                    placeholder: FieldPlaceholder.name.rawValue,
                    collapseButton: false
                )
                
                fieldView(
                    title: FieldTitle.patronymic.rawValue,
                    placeholder: FieldPlaceholder.patronymic.rawValue,
                    collapseButton: false
                )
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func fieldView(
        title: String,
        placeholder: String,
        collapseButton: Bool
    ) -> some View {
        
        HStack {
            
            InputView(
                inputState: .init(image: { .init(systemName: "person") }),
                inputEvent: { event in },
                config: setupConfig(title: title, placeholder: placeholder)
            )
            
            if collapseButton {
                
                Button(
                    action: { },
                    label: {
                        
                        Image(systemName: "chevron.up")
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
        title: String,
        placeholder: String
    ) ->  InputView.InputConfigView {
        
        .init(
            title: title,
            titleFont: config.titleFont,
            titleColor: config.titleColor,
            textFieldFont: config.textFieldFont,
            placeholder: placeholder,
            hint: nil,
            hintFont: config.hintFont,
            hintColor: config.hintColor,
            backgroundColor: config.backgroundColor,
            imageSize: .small
        )
    }
}

struct NameView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 20) {
                
                NameView(
                    state: .init(state: .collapse),
                    nameEvent: { state in },
                    config: .init(
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
                )
                
                NameView(
                    state: .init(state: .expended),
                    nameEvent: { state in },
                    config: .init(
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
                )
            }
        }
        .padding(.horizontal, 20)
    }
}
