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
    let nameEvent: NameEvent
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
                inputState: .init(image: { .init(systemName: "person") }, event: .loadImage),
                config: setupConfig(title: title, placeholder: placeholder)
            )
            
            if collapseButton {
                
                Button(
                    action: changeState,
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
                    viewModel: .init(state: .collapse),
                    changeState: {},
                    config: .init(
                        title: <#T##String#>,
                        titleFont: <#T##Font#>,
                        titleColor: <#T##Color#>, textFieldFont: <#T##Font#>, placeholder: <#T##String#>, hint: <#T##String?#>, hintFont: <#T##Font#>, hintColor: <#T##Color#>, backgroundColor: <#T##Color#>, imageSize: <#T##InputView.InputConfigView.ImageSize#>)
                            .init(
                        titleFont: .system(size: 12),
                        titleColor: .gray.opacity(0.8),
                        textFieldFont: .system(size: 14),
                        hintFont: .system(size: 10),
                        hintColor: .gray.opacity(0.7),
                        backgroundColor: .clear
                    )
                )
                
                NameView(
                    viewModel: .init(state: .expended),
                    changeState: {},
                    config: .init(
                        titleFont: .system(size: 12),
                        titleColor: .gray.opacity(0.8),
                        textFieldFont: .system(size: 14),
                        hintFont: .system(size: 10),
                        hintColor: .gray.opacity(0.7),
                        backgroundColor: .clear
                    )
                )
            }
        }
        .padding(.horizontal, 20)
    }
}
