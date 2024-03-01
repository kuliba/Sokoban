//
//  NameView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI

class NameViewModel: ObservableObject {
    
    var state: NameState
    
    init(state: NameState) {
        self.state = state
    }
    
    enum NameState {
        
        case collapse
        case expended
    }
}

struct NameView: View {
    
    var viewModel: NameViewModel
    
    @State private var text: String = ""
    let changeState: () -> Void
    
    let config: InputView.InputConfigView
    
    var body: some View {
        
        switch viewModel.state {
        case .collapse:
            
            fieldView(
                title: "ФИО Получателя",
                placeholder: "Введите ФИО Получателя",
                collapseButton: true
            )
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            
        case .expended:
            
            VStack {
                
                fieldView(
                    title: "Фамилия получателя*",
                    placeholder: "Введите Фамилию Получателя",
                    collapseButton: true
                )
                
                fieldView(
                    title: "Имя получателя*",
                    placeholder: "Введите Имя Получателя",
                    collapseButton: false
                )
                
                fieldView(
                    title: "Отчество получателя (если есть)",
                    placeholder: "Введите Отчество Получателя",
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
                icon: .small,
                image: .init(systemName: "person"),
                title: title,
                placeholder: placeholder,
                hint: nil,
                config: setupConfig()
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
    
    private func setupConfig() ->  InputView.InputConfigView {
        
        .init(
            titleFont: config.titleFont,
            titleColor: config.titleColor,
            textFieldFont: config.textFieldFont,
            hintFont: config.hintFont,
            hintColor: config.hintColor,
            backgroundColor: config.backgroundColor
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
