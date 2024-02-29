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
            
            HStack {
                
                InputView(
                    icon: .small,
                    image: .init(systemName: "photo.artframe"),
                    title: "ФИО Получателя",
                    placeholder: "Введите ФИО Получателя",
                    hint: nil,
                    config: setupConfig()
                )
                
                Button(
                    action: changeState,
                    label: {
                        
                        Image(systemName: "chevron.up")
                            .foregroundColor(Color.gray.opacity(0.7))
                    })
                
            }
            .padding(.trailing, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
        case .expended:
            
            VStack {
                
                HStack {
                    
                    InputView(
                        icon: .small,
                        image: .init(systemName: "photo.artframe"),
                        title: "Фамилия получателя*",
                        placeholder: "Введите Фамилию Получателя",
                        hint: nil,
                        config: setupConfig()
                    )
                    
                    Button(
                        action: changeState,
                        label: {
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.gray.opacity(0.7))
                        })
                    
                }
                .padding(.trailing, 16)
                
                InputView(
                    icon: .small,
                    image: .init(systemName: ""),
                    title: "Имя получателя*",
                    placeholder: "Введите Имя Получателя",
                    hint: nil,
                    config: setupConfig()
                )
                
                InputView(
                    icon: .small,
                    image: .init(systemName: ""),
                    title: "Отчество получателя (если есть)",
                    placeholder: "Введите Отчество Получателя",
                    hint: nil,
                    config: setupConfig()
                )
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    func setupConfig() ->  InputView.InputConfigView {
        
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
